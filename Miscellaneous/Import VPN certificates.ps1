<#
.SYNOPSIS
Small script to import certificates in Windows unattended (e.g. with Intune) for Windows VPN for example. It's a dirty way, but it works.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION
Script to:
Create Scripts folder;
Create VPN Folder
Decodes the embedded VPN certificates for next task;
Imports the vpn certificates;
Cleans up;
Logs everything.

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Encode certificates using lines 27-38, then copy/paste contents to lines 53 & 54 (and save the script);
- Run script in an elevated (administrator) Powershell prompt or upload to Intune for use there;
#>

<#
Encode & decode certificates for reference.
#Create first encoded certificate (Root CA cert)
$Content = Get-Content -Path C:\temp\Certs\YourRootCertName.cer -Encoding Byte
$RootCert = [System.Convert]::ToBase64String($Content)
$RootCert | Out-File C:\temp\Certs\YourRootCertName.cer-Encoded.txt
#Open created textfile and copy/paste contents to line 57

#Create first encoded certificate (actual VPN cert)
$Content = Get-Content -Path C:\temp\Certs\YourVPNCertName.pfx -Encoding Byte
$ChildCert = [System.Convert]::ToBase64String($Content)
$ChildCert | Out-File C:\temp\Certs\YourVPNCertName.pfx-Encoded.txt
#Open created textfile and copy/paste contents to line 58
#>

#create folder
if (Test-Path 'C:\Scripts\VPN') {
}
else {
    New-Item -Path "c:\" -Name "Scripts" -ItemType "directory"
    New-Item -Path "c:\Scripts\" -Name "VPN" -ItemType "directory"
}

Start-transcript "c:\Scripts\Logs\VPN certificates.log" -Force

#region decode VPN certificates
#variables
$RootCertEncoded = "ContentFromLine31"
$ChildCertEncoded = "ContentFromLine37"

#Decode first encoded certificate
$Content = [System.Convert]::FromBase64String($RootCertEncoded)
Set-Content -Path C:\scripts\vpn\YourRootCertName.cer -Value $Content -Encoding Byte

#Decode second encoded certificate
$Content = [System.Convert]::FromBase64String($ChildCertEncoded)
Set-Content -Path C:\scripts\vpn\YourVPNCertName.pfx -Value $Content -Encoding Byte
#endregion

#region import certificates
$Password = ConvertTo-SecureString "YourCertPassword" -AsPlainText -Force
Import-Certificate -Filepath C:\scripts\VPN\YourRootCertName.cer -CertStoreLocation Cert:\LocalMachine\Root\
Import-PfxCertificate -Filepath C:\scripts\VPN\YourVPNCertName.pfx -Password $Password -CertStoreLocation Cert:\LocalMachine\My\
#endregion

#Cleanup after ourselves
Remove-item c:\scripts\vpn -Recurse -Force

Stop-Transcript