<#
.SYNOPSIS
Script for use with Intune to fix if registry keys have the correct value. 

.AUTHOR 
# Reg2CI (c) 2022 by Roger Zander https://github.com/rzander/REG2CI/ / https://reg2ps.azurewebsites.net/
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script for use with Intune to fix if registry keys have the correct value.  
More specifically: a couple of settings from the CIS L2 W11 baseline that are unable to deploy with Intune natively (partly because they are for Windows AD)

This script will set the registry settings and Continue if it's already set properly.

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Deploy this script in Intune.
#>

if (Test-Path "C:\Scripts\Logs" ) {
}
else {
    New-Item -Path "c:\" -Name "Scripts" -ItemType "directory"
    New-Item -Path "c:\Scripts\" -Name "Logs" -ItemType "directory"
}

Start-transcript "C:\Scripts\Logs\CIS registry keys deployment script.log" -Force
Write-Host "One-time deployment of the CIS L2 registry settings."

if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Print") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Print" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters") -ne $true) {  New-Item "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork\Biometrics") -ne $true) {  New-Item "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork\Biometrics" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Peernet") -ne $true) {  New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Peernet' -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -force -ea Continue };
if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System") -ne $true) {  New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -force -ea Continue };



New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses' -Name 'PCI Express Upstream Switch Port' -Value 'PCI\VEN_8086&DEV_15C0' -PropertyType String -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'crashonauditfail' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'disabledomaincreds' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'everyoneincludesanonymous' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'forceguest' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymoussam' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymous' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'scenoapplylegacyauditpolicy' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RunAsPPL' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'allownullsessionfallback' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Print' -Name 'RpcAuthnLevelPrivacyEnabled' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'ProtectionMode' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel' -Name 'obcaseinsensitive' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths' -Name 'Machine' -Value @("System\CurrentControlSet\Control\ProductOptions","System\CurrentControlSet\Control\Server Applications","Software\Microsoft\Windows NT\CurrentVersion") -PropertyType MultiString -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'restrictnullsessaccess' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'NullSessionPipes' -Value @("") -PropertyType MultiString -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'nullsessionshares' -Value @("") -PropertyType MultiString -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'autodisconnect' -Value 15 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'enableforcedlogoff' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'smbservernamehardeninglevel' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -Name 'NodeType' -Value 2 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -Name 'DoHPolicy' -Value 2 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'DisablePasswordChange' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'MaximumPasswordAge' -Value 30 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'RequireStrongKey' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork\Biometrics' -Name 'EnableESSwithSupportedPeripherals' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography' -Name 'forcekeyprotection' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect' -Name 'RequirePinForPairing' -Value 2 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox' -Name 'AllowClipboardRedirection' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox' -Name 'AllowNetworking' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}' -Name 'ScenarioExecutionEnabled' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers' -Name 'CopyFilesPolicy' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcUseNamedPipeProtocol' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcAuthentication' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcProtocols' -Value 5 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'ForceKerberosForRpc' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcTcpPort' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'EnableNetbios' -Value 2 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'DoHPolicy' -Value 2 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fDisableLocationRedir' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'EnableUiaRedirection' -Value 0 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fDisableWebAuthn' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client' -Name 'DisableCloudClipboardIntegration' -Value 1 -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Peernet' -Name 'Disabled' -Value '1' -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC' -Name 'PreventHandwritingDataSharing' -Value '1' -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports' -Name 'PreventHandwritingErrorReports' -Value '1' -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'AllowCrossDeviceClipboard' -Value '1' -PropertyType DWord -Force -ea Continue;
New-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities' -Value '0' -PropertyType DWord -Force -ea Continue;


Stop-Transcript