<#
.SYNOPSIS
Script to create a registry item to show file extensions, hidden files and folders.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Creates a registry item to show file extensions, hidden files and folders.
Both hidden:
"Hidden"=dword:00000002
"HideFileExt"=dword:00000001

Both shown:
"Hidden"=dword:00000001
"HideFileExt"=dword:00000000

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Change DWORD value to suit your needs
- Run script in an elevated (administrator) Powershell prompt;
#>

if (Test-Path "C:\Scripts\Logs" ) {
}
else {
    New-Item -Path "c:\" -Name "Scripts" -ItemType "directory"
    New-Item -Path "c:\Scripts\" -Name "Logs" -ItemType "directory"
}

Start-Transcript "C:\Scripts\Logs\Deploy explorer registry settings.log" -Force
Write-Host "One-time deployment of the File explorer registry settings (to show file extensions and hidden files)."

New-PSDrive HKU Registry HKEY_USERS | out-null
$user = get-wmiobject -Class Win32_Computersystem | select Username;
$sid = (New-Object System.Security.Principal.NTAccount($user.UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value;
$key = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$val = (Get-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced") | out-null
$reg = Get-Itemproperty -Path $key -Name Hidden -erroraction 'silentlycontinue'
$reg2 = Get-Itemproperty -Path $key -Name Hidden -erroraction 'silentlycontinue'


if(-not($reg))
	{
		Write-Host "Registry key didn't exist, creating it now"
                New-Itemproperty -path $Key -name "Hidden" -value "1"  -PropertyType "DWord" | out-null
		exit 1
	} 
else
	{
 		Write-Host "Registry key changed to 1"
		Set-ItemProperty  -path $key -name "Hidden" -value "1" | out-null
		Exit 0  
	}

	
	if(-not($reg2))
	{
		Write-Host "Registry key didn't exist, creating it now"
                New-Itemproperty -path $Key -name "HideFileExt" -value "0"  -PropertyType "DWord" | out-null
		exit 1
	} 
else
	{
 		Write-Host "Registry key changed to 1"
		Set-ItemProperty  -path $key -name "HideFileExt" -value "0" | out-null
		Exit 0  
	}
	
Stop-Transcript