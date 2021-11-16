<#
.SYNOPSIS
Script to retrieve the local Exchange version for each Exchange server in your organization.
Should work with all versions of Exchange starting from 2013.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
See .SYNOPSIS

.REQUIREMENTS
- Correct Exchange Powershell Module
- Correct permissions on the Exchange server

.INSTRUCTIONS
- Run script in an elevated (administrator) Exchange Powershell prompt an Exchange server.
- Optionally check the build number online: https://docs.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates?view=exchserver-2019
#>

Get-ExchangeServer | select name, admindisplayversion