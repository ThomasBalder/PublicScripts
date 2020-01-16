<#
.SYNOPSIS
Script to get all computers who have not contacted AD in 60 days, and exports it to csv.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V4;
- ActiveDirectory module (obviously).

.INSTRUCTIONS
- Change the number of days if needed;
- Run script in an elevated (administrator) Powershell prompt on a DC or a machine with RSAT.
#>

$Date = (Get-Date).AddDays(-60)
Get-ADComputer -filter {Enabled -eq $true -and LastLogonDate -lt $Date} -Properties LastLogonDate | Select-Object Name,Description,DistinguishedName,LastLogonDate `
| Export-CSV C:\temp\InactiveComputers.csv -NoTypeInformation -Encoding UTF8