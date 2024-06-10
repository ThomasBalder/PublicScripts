<#
.SYNOPSIS
Small script to configure choco update settings to weekly search and install package updates.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to configure chocolaty update settings. 

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in (UAC) admin Powershell prompt, or configure to be run as system from i.e. Intune.
#>

Start-Transcript "C:\Scripts\Logs\Choco package upgrade.log"

#Task variables
$TaskAction = New-ScheduledTaskAction -Execute '"C:\ProgramData\chocolatey\choco.exe"' -Argument 'upgrade all -y'
$TaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 11am
$TaskName = 'Chocolatey package upgrade Schedule'
$TaskDescription = 'Runs Chocolatey package upgrader weekly on Wednesday at 11AM, and installs available updates.'
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
$TaskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8

#Work
Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -TaskName $TaskName -Description $TaskDescription -Principal $TaskPrincipal -Settings $TaskSettings

Stop-Transcript
