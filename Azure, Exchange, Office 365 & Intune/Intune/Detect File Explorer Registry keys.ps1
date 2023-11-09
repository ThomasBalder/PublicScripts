<#
.SYNOPSIS
Script to create a registry item to show file extensions, hidden files and folders.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Detects the registry item to show file extensions, hidden files and folders. Works with the remediation script.
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

Start-Transcript "C:\Scripts\Logs\File explorer registry settings-detection.log" -Force

New-PSDrive HKU Registry HKEY_USERS | out-null
$user = get-wmiobject -Class Win32_Computersystem | select Username;
$sid = (New-Object System.Security.Principal.NTAccount($user.UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value;
$key = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$value1 = (Get-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced");
$key2 = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$value2 = (Get-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced");

$Hidden = $value1.GetValue("Hidden");
$HideFileExt = $value2.GetValue("HideFileExt");

##################################
#Launch Hidden Detection         #
##################################

if($Hidden -ne 1)
{
    Write-Host "Key present, no remediation needed."
    Exit 1
}
else
{
    Write-Host "Key not present. Needs remediation."
    Exit 0
}

if($HideFileExt -ne 0)
{
    Write-Host "Key present, no remediation needed."
    Exit 1
}
else
{
    Write-Host "Key not present. Needs remediation."
    Exit 0
}

Stop-Transcript