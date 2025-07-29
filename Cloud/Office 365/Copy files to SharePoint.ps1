<#
.SYNOPSIS
Script to copy EFT XML files from our sFTP server to a SharePoint site.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to create a checksum file for allXML file in folders, and copies the folders and files to a SharePoint site. 
It also checks and deletes files older than 6 months and logs most things.

.REQUIREMENTS
- At least Powershell V5
- Microsoft.Graph module (tested with v2.24.0)
- Enterprise app with self signed certificate (which is installed in the system personal store) and proper MS Graph API permissions
-- The enterprise app is used for userless authentication.

.INSTRUCTIONS
- Change variables such as file extension (i.e. .xml, Sharepoint site, tenant and app ID.
- Run script in a Powershell prompt and/or run as a scheduled task
#>

# Set logging options
$LogFolder = "C:\Scripts\Logs"
if (-not (Test-Path $LogFolder)) { New-Item -ItemType Directory -Path $LogFolder | Out-Null }
$LogFile = Join-Path $LogFolder ("Copy ..  files to SharePoint_{0}.log" -f (Get-Date -Format "yyyy-MM-dd_HHmm"))
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd_HHmm"
    $Entry = "$TimeStamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $Entry
}

# Remove old (14+ days) log files
Get-ChildItem -Path $LogFolder -File -Filter "Copy ..  files to SharePoint_*.log" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) } | Remove-Item -Force

#Region XML & checksum files
$RootFolder = "C:\sFTProot\test\RE test"
$CurrentDate = Get-Date
$RetentionPeriod = $CurrentDate.AddMonths(-6)

# Clean up old XML and checksum files
Write-Log "Deleting files older than 6 months..."
$OldFiles = Get-ChildItem -Path $RootFolder -Recurse -Include *.xml, *-checksum.txt | Where-Object {
    $_.LastWriteTime -lt $RetentionPeriod
}

if ($OldFiles.Count -eq 0) {
    Write-Log "No old files found to delete."
}
else {
    foreach ($File in $OldFiles) {
        Write-Log "Deleting: $($File.FullName)"
        Remove-Item -Path $File.FullName -Force
    }
}

# Create checksum files
Write-Log "Generating checksums..."
Get-ChildItem -Path $RootFolder -Recurse -Filter *.xml | ForEach-Object {
    $XmlFile = $_.FullName
    $ChecksumPath = Join-Path -Path $_.DirectoryName -ChildPath ($_.BaseName + "-checksum.txt")

    if (Test-Path $ChecksumPath) {
        Write-Log "Checksum already exists for: $($_.Name)"
        return
    }

    $Bytes = [System.IO.File]::ReadAllBytes($XmlFile)
    $Sha256 = [System.Security.Cryptography.Sha256]::Create()
    $HashBytes = $Sha256.ComputeHash($Bytes)
    $HashString = [BitConverter]::ToString($HashBytes) -replace '-', ''
    $HashString | Out-File -FilePath $ChecksumPath -Encoding ASCII
    Write-Log "Checksum saved: $ChecksumPath"
}
#endregion

# Variables
$TenantId = "yourtentantid"
$AppId = "yourappid"

Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateName "CN=yourcertsubject" -NoWelcome

# Get Site and Drive
Write-Log "Get site."
$Site = Get-MgSite -Site "yourtenant.sharepoint.com:/sites/ReFinancetest"
Write-Log "Site Display Name: $($Site.DisplayName)"
Write-Log "Site Web URL: $($Site.WebUrl)"
Write-Log "Site ID: $($Site.Id)"

# Get the "Documents" library as a List
Write-Log "Get "Documents" library."
$List = Get-MgSiteList -SiteId $Site.Id | Where-Object { $_.DisplayName -eq "Documents" }
Write-Log "List Display Name: $($List.DisplayName)"
Write-Log "List ID: $($List.Id)"
Write-Log "List Web URL: $($List.WebUrl)" 

# Get the Drive associated with the List (library)
Write-Log "Get the drive associated with the List (This is the actual drive behind the document library)"
$Drive = Get-MgSiteListDrive -SiteId $Site.Id -ListId $List.Id
Write-Log "Drive Name: $($Drive.Name)"
Write-Log "Drive ID: $($Drive.Id)"
Write-Log "Drive Type: $($Drive.DriveType)"


# Get the root item (Documents root folder)
Write-Log "Get the root folder of the library."
$RootItem = Get-MgDriveRoot -DriveId $Drive.Id
Write-Log "Root Folder ID: $($RootItem.Id)"
Write-Log "Root Folder Name: $($RootItem.Name)"

# Upload all .xml and -checksum.txt files to SharePoint
Write-Log "Starting upload to SharePoint Site: '$($Site.DisplayName)', Library: '$($List.DisplayName)' from local path: '$RootFolder'"

Get-ChildItem -Path $RootFolder -Recurse -Include *.xml, *-checksum.txt | ForEach-Object {
    $RelativePath = $_.FullName.Substring($RootFolder.Length + 1) -replace '\\', '/'
    $Parts = $RelativePath -split '/'
    if ($Parts.Length -gt 1) {
        $FolderParts = $Parts[0..($Parts.Length - 2)]
    }
    else {
        $FolderParts = @()
    }
    $FileName = $_.Name
    $CurrentFolderId = $RootItem.Id  # Start from Documents root
    # Walk the folder path and create missing folders
    foreach ($Folder in $FolderParts) {
        # Check if folder exists
        $ExistingFolder = Get-MgDriveItemChild -DriveId $Drive.Id -DriveItemId $CurrentFolderId -Filter "name eq '$Folder'" -ErrorAction SilentlyContinue | Where-Object { $_.Folder }
        if ($ExistingFolder) {
            $CurrentFolderId = $ExistingFolder.Id
        }
        else {
            # Create folder
            $Body = @{
                name                                = $Folder
                folder                              = @{ }
                "@microsoft.graph.conflictBehavior" = "replace"
            } | ConvertTo-Json -Depth 3
            $NewFolder = Invoke-MgGraphRequest -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/drives/$($Drive.Id)/items/$($CurrentFolderId)/children" `
                -Body $body `
                -ContentType "application/json"

            $CurrentFolderId = $NewFolder.id
        }
    }
    # Create relative path for upload
    $RelativeUploadPath = ($FolderParts + $FileName) -join '/'

    # Upload files
    $UploadUrl = "https://graph.microsoft.com/v1.0/drives/$($Drive.Id)/root:/$($RelativeUploadPath):/content"
    Write-Log "Uploading to: $RelativeUploadPath"

    Invoke-MgGraphRequest -Method PUT `
        -Uri $UploadUrl `
        -Body ([System.IO.File]::ReadAllBytes($_.FullName)) `
        -ContentType "application/octet-stream"
}
Write-Log "All files uploaded."