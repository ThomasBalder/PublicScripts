<#
.SYNOPSIS
Small script to get an overview of all certificates that are about to expire.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V4 .

.INSTRUCTIONS
- Change variables where needed;
- Run script in an elevated (administrator) Powershell prompt on the machine you want to check.

#>

$days = "75"
$outputpath = "C:\Temp"

#Get certificate expiration and exports to CSV
Get-ChildItem -Path cert: -Recurse -ExpiringInDays $days | Select-Object FriendlyName, NotAfter, Thumbprint, Subject, Issuer | Export-Csv -Path $outputpath\ExpiredCertificates.CSV -NoTypeInformation