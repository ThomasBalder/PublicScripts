<#
.SYNOPSIS
Script to export all domain computers in AD to CSV.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to export all domain computers in AD to CSV.
Includes:
- Name;
- Description (i.e. user);
- DistinguishedName (so you can check which OU it's in)
- OS (& OS build);
- Lastlogondate (so you can check if it's a machine that's active);
- State (wether or not it's enabled).

.REQUIREMENTS
- At least Powershell V4
- ActiveDirectory module (obviously)

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt on a DC or a machine with RSAT.
#>

Get-ADComputer -Filter * -Property * | Select-Object Name,Description,DistinguishedName,OperatingSystem,OperatingSystemVersion,LastLogonDate,Enabled `
| Export-CSV C:\temp\AllComputers.csv -NoTypeInformation -Encoding UTF8