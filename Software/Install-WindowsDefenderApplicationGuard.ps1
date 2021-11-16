<#
.SYNOPSIS
Oneliner to install  Windows Defender Application Guard

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
#>

Start-transcript "c:\scripts\logs\Windows Defender Application Guard.log"

Enable-WindowsOptionalFeature -online -FeatureName Windows-Defender-ApplicationGuard -NoRestart

Stop-transcript