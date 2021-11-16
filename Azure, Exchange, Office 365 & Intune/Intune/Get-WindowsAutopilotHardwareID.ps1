<#
.SYNOPSIS
Script to manually get the hardware ID from a machine to import into Intune / Autopilot. Designed for testing Autopilot and to be run from a thumbdrive (w/ driveletter D: )

.AUTHOR 
Thomas Balder (inspired by others) - Based on the script from Michael Niehaus @ https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
This script:
- Creates a directory called "HWID" on the C-drive from a machine;
- Downloads and installs the latest version of the "Get-WindowsAutoPilotInfo.ps1" script
- Runs afore mentioned script and outputs it 

.REQUIREMENTS
- At least Powershell V5
- Working internet connection

.INSTRUCTIONS
- Change the driveltter on line 30 if oyu think your thumbdrive has a different driveletter;
- Run script in an elevated (administrator) Powershell prompt on a running Windows 10 machine.
#>

mkdir c:\HWID
Set-Location c:\HWID
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
$hostname = hostname
Install-Script -Name Get-WindowsAutopilotInfo -Force
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Get-WindowsAutopilotInfo.ps1 -OutputFile d:\$hostname.csv