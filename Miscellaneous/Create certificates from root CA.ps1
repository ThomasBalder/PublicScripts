#From Root CA Powershell:

# ROOT
$cert = Get-ChildItem -Path "Cert:\LocalMachine\Root\5b8d492752f340157634af4981d06c0e5f68bc92" #thumbprint is from rootCA cert

# Child (multiple)
New-SelfSignedCertificate -Type Custom -DnsName ContosoWifi -KeySpec Signature `
    -Subject "CN=ContosoWifi" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") -NotAfter '04-05-2024' #change this date to any futer date

