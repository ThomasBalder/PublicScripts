<#
.SYNOPSIS
Script to install and change the (update) settings for the Zoom client.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in a 64bit Powershell process. In Intune, change the "Run script in 64 bit PowerShell Host" to YES. 
Otherwise an error stating that the regkey cannot be found will appear.

#>
Start-Transcript "C:\Scripts\logs\Configure Zoom Settings.log" -force

# Install Zoom if not installed
$localprograms = choco list --localonly
if ($localprograms -like "*zoom*") {
  
    # Enable auto-updates
    Write-host "Attempting to enable autoupdate."
    $count = 0
    $success = $null

    do {
        try {
            New-ItemProperty -Path 'HKLM:\SOFTWARE\Zoom\MSI' -PropertyType String -Name 'EnableClientAutoUpdate' -Value 'True' 
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Zoom\MSI' -name 'DisableUpdate' -Value 'false' -ErrorAction Stop
            $success = $true
        }
        catch {
            Write-Output "Registry keys not found. Next attempt in 30 seconds"
            Start-sleep -Seconds 30
        }
        $count++
    }until($count -eq 2 -or $success)
}

Stop-transcript