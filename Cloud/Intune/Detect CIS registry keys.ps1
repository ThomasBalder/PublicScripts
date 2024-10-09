<#
.SYNOPSIS
Script for use with Intune remedation tool to detect if registry keys have the correct value. 

.AUTHOR 
# Reg2CI (c) 2022 by Roger Zander https://github.com/rzander/REG2CI/ / https://reg2ps.azurewebsites.net/
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script for use with Intune remedation tool to detect if registry keys have the correct value.  
More specifically: a couple of settings from the CIS L2 W11 baseline that are unable to deploy with Intune natively (partly because they are for Windows AD)

This is the detection script. If a regkey is not like stated below, it will trigger the remedation script to fix it.

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Deploy this detection script in Intune, setup the Intune part, and profit!
#>

if (Test-Path "C:\Scripts\Logs" ) {
}
else {
    New-Item -Path "c:\" -Name "Scripts" -ItemType "directory"
    New-Item -Path "c:\Scripts\" -Name "Logs" -ItemType "directory"
}

Start-transcript "C:\Scripts\Logs\CIS registry keys-detection.log" -Force

	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses")){Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Print")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork\Biometrics")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
    if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
    if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if(-NOT (Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")){ Write-Host "Key not present. Needs remediation." 
	exit 1  };

	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses' -Name 'PCI Express Upstream Switch Port' -ea Continue) -eq 'PCI\VEN_8086&DEV_15C0') {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'crashonauditfail' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'disabledomaincreds' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'everyoneincludesanonymous' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'forceguest' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymoussam' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymous' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'scenoapplylegacyauditpolicy' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RunAsPPL' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'allownullsessionfallback' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Print' -Name 'RpcAuthnLevelPrivacyEnabled' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'ProtectionMode' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel' -Name 'obcaseinsensitive' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths' -Name 'Machine' -ea Continue) -join ',' -eq '"System\CurrentControlSet\Control\ProductOptions,System\CurrentControlSet\Control\Server Applications,Software\Microsoft\Windows NT\CurrentVersion"') {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'restrictnullsessaccess' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'NullSessionPipes' -ea Continue) -join ',' -eq '""') {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'nullsessionshares' -ea Continue) -join ',' -eq '""') {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'autodisconnect' -ea Continue) -eq 15) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'enableforcedlogoff' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'smbservernamehardeninglevel' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -Name 'NodeType' -ea Continue) -eq 2) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -Name 'DoHPolicy' -ea Continue) -eq 2) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'DisablePasswordChange' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'MaximumPasswordAge' -ea Continue) -eq 30) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'RequireStrongKey' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork\Biometrics' -Name 'EnableESSwithSupportedPeripherals' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography' -Name 'forcekeyprotection' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect' -Name 'RequirePinForPairing' -ea Continue) -eq 2) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox' -Name 'AllowClipboardRedirection' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox' -Name 'AllowNetworking' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}' -Name 'ScenarioExecutionEnabled' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers' -Name 'CopyFilesPolicy' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcUseNamedPipeProtocol' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcAuthentication' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcProtocols' -ea Continue) -eq 5) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'ForceKerberosForRpc' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -Name 'RpcTcpPort' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'EnableNetbios' -ea Continue) -eq 2) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'DoHPolicy' -ea Continue) -eq 2) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fDisableLocationRedir' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'EnableUiaRedirection' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fDisableWebAuthn' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client' -Name 'DisableCloudClipboardIntegration' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Peernet' -Name 'Disabled' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1 };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC' -Name 'PreventHandwritingDataSharing' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
    if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReport' -Name 'PreventHandwritingErrorReports' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'AllowCrossDeviceClipboard' -ea Continue) -eq 1) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };
	if((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'UploadUserActivities' -ea Continue) -eq 0) {  } else { Write-Host "Key not present. Needs remediation." 
	exit 1  };


Stop-Transcript