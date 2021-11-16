<#
.SYNOPSIS
Small script to configure Lenovo System update to weekly search and install system updates.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to configure Lenovo system update. 
- Creates a registry key for the Lenovo System updater;
- Creates a new scheduled task with correct parameters to run the updater with the parameters (to be found in "Deployment Guide:
Lenovo System Update Suite" PDF, chapter 5.1 System update > Command line);
- Disables native installed Lenovo update scheduled tasks (as per requirement from Lenovo);

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in (UAC) admin Powershell prompt, or configure to be run as system from i.e. Intune.
#>

Start-Transcript "C:\Scripts\Logs\Lenovo System Update.log"

#Registry variables
$RegPath = 'HKLM:\SOFTWARE\WOW6432Node\Policies\Lenovo\System Update\UserSettings\General'

#Task variables
$TaskAction = New-ScheduledTaskAction -Execute '"C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"' -Argument '/CM'
$TaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At 11am
$TaskName = 'Lenovo System Update Schedule'
$TaskDescription = 'Runs Lenovo System Update weekly on Tuesday at 11AM, and installs available updates.'
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
$TaskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8

#Work
if ($RegPath -eq $true) { Write-Host "RegPath already exists!" }
else {
    New-Item $RegPath -Force
    New-ItemProperty $regPath -PropertyType String -Name AdminCommandLine -Value "/CM -search A -action INSTALL -includerebootpackages 1,3,4,5 -nolicense -defaultupdate" -Force
    New-ItemProperty $regPath -PropertyType String -Name DisplayLicenseNoticeSU -Value NO 
    New-ItemProperty $regPath -PropertyType String -Name DisplayLicenseNotice -Value NO
    New-ItemProperty $regPath -PropertyType String -Name AskBeforeClosing -Value NO
    New-ItemProperty $regPath -PropertyType String -Name DebugEnable -Value YES
    New-ItemProperty $regPath -PropertyType String -Name MetricsEnabled -Value YES  
}

Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -TaskName $TaskName -Description $TaskDescription -Principal $TaskPrincipal -Settings $TaskSettings
Get-ScheduledTask -TaskPath "\TVT\" | Disable-ScheduledTask

Stop-Transcript
