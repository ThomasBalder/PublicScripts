<#
.SYNOPSIS
Script to get all users who have not contacted AD in 90 days, and exports it to csv.

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

Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90 | ?{$_.enabled -eq $True} | Get-ADUser -Properties Name, EmailAddress, Department, Description, lastLogonTimestamp | Select Name, EmailAddress, Department, Description,@{n='lastLogonTimestamp';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | Export-CSV C:\temp\InactiveUsers.csv -NoTypeInformation -Encoding UTF8