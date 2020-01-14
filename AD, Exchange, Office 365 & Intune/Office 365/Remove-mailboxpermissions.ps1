<#
.SYNOPSIS
Small script to remove mailboxpermissions (both Fullacces as SendAs)

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
See .SYNOPSIS.

.REQUIREMENTS
- At least Powershell V5;
- ExchangeOnline module (can be installed with the one-liner below):
Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
- Correct permissions on both AD and O365;
- Logs the process for troubleshooting.

.INSTRUCTIONS
- Change csv location on line 35;
- Run script in an elevated (administrator) Powershell prompt;
#>

#Start logging
Start-Transcript -Path "c:\temp\Remove-MailboxPermissions.txt" -Force
Write-Host "The logs of this process are written to c:\temp\Remove-MailboxPermissions.txt" -ForegroundColor Magenta

#Connect to Office 365
Write-Host "Connecting to Office 365. Please log in with your administrator credentials." -ForegroundColor Yellow
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
. "$MFAExchangeModule" | out-Null
Connect-EXOPSSession 

#Remove FullAccess mailbox permissions
$Mailboxes = Import-Csv -Path C:\temp\Mailbox.csv
$mailboxes | ForEach-Object {
    Remove-MailboxPermission -Identity $_.Identity -User $_.user -AccessRights FullAccess -Confirm:$false
}

#Remove SendAs rights
$mailboxes | ForEach-Object {
    Remove-RecipientPermission  -Identity $_.Identity -Trustee $_.user -AccessRights SendAs -Confirm:$false 
}

#Time to clean up
Write-Host "Everything is finished, so the connection to Office 365 is being closed." -ForegroundColor Green
Write-Host "Notepad wil open with the logfile, so you can check for errors." -ForegroundColor Green
Write-Host "Thank you, and until next time." -ForegroundColor Green
Get-pssession | Remove-pssession

Invoke-item "c:\temp\Remove-MailboxPermissions.txt"

Stop-Transcript