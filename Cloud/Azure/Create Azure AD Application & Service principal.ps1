<#
.SYNOPSIS
Script to create Azure AD application for authentication with app-id instead of username/password.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to create Azure AD application for authentication with app-id instead of username/password.
After that you can copy details to embed in your own script (i.e. user creation).

.REQUIREMENTS
- At least Powershell V5
- Azure AD Powershell module

.INSTRUCTIONS
- Run script rules one by one.

#>

#Region one time creation
#Create and export certificate on your CA
$signer = Get-ChildItem -Path "Cert:\LocalMachine\Root\A4026B63AF30BFCEE34CE5E86E8F2BD8F0C414E5" #this is optional so we can use our root ca cert. 
$certpwd = "enteryourcertpwhere"
$notAfter = (Get-Date).AddMonths(3) # Valid for 3 months
$thumb = (New-SelfSignedCertificate -DnsName "AzureApplicationName.yourdomain.com"  -CertStoreLocation "cert:\LocalMachine\My" -signer $signer `
        -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint 
$certpwd = ConvertTo-SecureString -String $certpwd -Force -AsPlainText
Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath c:\temp\certificatename.pfx -Password $certpwd

#Import the certificate to the machine you want the create the app from
Import-PfxCertificate -FilePath c:\temp\certificatename.pfx -Password $certpwd -CertStoreLocation Cert:\LocalMachine\My\

#Import the same certificate to memory
$importcert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\temp\certificatename.pfx", $certpwd)
$keyValue = [System.Convert]::ToBase64String($importcert.GetRawCertData())

#Create the Azure AD application
$application = New-AzureADApplication -DisplayName "Your Azure Application name" -IdentifierUris "https://AzureApplicationName.yourdomain.com"
$notAfter = (Get-Date).AddMonths(3) # This should be the same period as on your certificate
New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier "YourPasswordHere" -Type AsymmetricX509Cert -Usage Verify -Value $keyValue -EndDate $notAfter
Write-Host "Please write down the application and object ID for later use."
Write-Host "If you forget this, you can always look this up on the overview page from the application"

#Create Service Principal
$sp = New-AzureADServicePrincipal -AppId $application.AppId

#Grant the created Service Principal read permissions. You can change this to whatever suits you.
Add-AzureADDirectoryRoleMember -ObjectId (Get-AzureADDirectoryRole | where-object { $_.DisplayName -eq "Directory Readers" }).Objectid -RefObjectId $sp.ObjectId

#Display tenant details
$tenant = Get-AzureADTenantDetail
Write-Host "Please write down the tenant ID"
Write-Host "All done. You can use the following command in script to connect to Azure:"
Write-Host "Connect-AzureAD -TenantId 'yourtenantid' -ApplicationId  'yourapplicationid' -CertificateThumbprint 'yourcertificatethumbprint'"
Write-Host "Be aware: said certificate must be installed on the machine you want to run the script from."



