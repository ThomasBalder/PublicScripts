<#
.SYNOPSIS
Simple script to backup Bitlocker key to Azure AD. Compatible for deployment via Intune.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Simple script to backup Bitlocker key to Azure AD. Also writes a logfile for troubleshooting purposes.

.REQUIREMENTS
- Windows 10 Pro 1803 or higher
- General Bitlocker requirements
- Azure

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt or upload to Intune as a Powershell script;
#>

Start-Transcript "c:\scripts\Transcript Bitlocker.log" -force

$BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

stop-transcript