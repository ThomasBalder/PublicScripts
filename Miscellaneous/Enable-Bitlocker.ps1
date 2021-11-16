<#
.SYNOPSIS
Script to enable Bitlocker disk encryption silently. Compatible for deployment via Intune.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Enables Bitlcoker drive encryption without user intervention, and backups the key to both Azure AD and local AD.
Built in wait moments and redundant variables so the proper keys get backupped. Also writes a logfile for troubleshooting purposes.

.REQUIREMENTS
- Windows 10 Pro 1803 or higher
- General Bitlocker requirements
- General Bitlocker GPO requirements (for backup to local AD)
- Azure

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt or upload to Intune as a Powershell script;
#>

Start-Transcript "c:\Scripts\Logs\Bitlocker.log" -force

$BLinfo = Get-Bitlockervolume
$BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
if ($BLinfo.EncryptionPercentage -ne '100' -and $BLinfo.EncryptionPercentage -ne '0') {
    Resume-BitLocker -MountPoint "C:"
    Start-Sleep -Seconds 5
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
}
if ($BLinfo.VolumeStatus -eq 'FullyEncrypted' -and $BLinfo.ProtectionStatus -eq 'Off') {
    Resume-BitLocker -MountPoint "C:"
    Start-Sleep -Seconds 5
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
}
if ($BLinfo.EncryptionPercentage -eq '0') {
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -SkipHardwareTest -RecoveryPasswordProtector
    Start-Sleep -Seconds 5
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
}
Start-Sleep -Seconds 5
$BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

stop-transcript