<#
.SYNOPSIS
Script to list all -shared- mailboxes and their accessrights.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
See .SYNOPSIS

.REQUIREMENTS
- At least Powershell V5;
- ExchangeOnline module (can be installed with the one-liner below):
Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
- Correct permissions on both AD and O365.

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt.
#>

#Connect to Office 365
Write-Host "Connecting to Office 365. Please log in with your administrator credentials." -ForegroundColor Yellow
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
. "$MFAExchangeModule" | out-Null
Connect-EXOPSSession 

# Setup temp storage location for reports
$outputpath = Read-Host -Prompt "Please enter the path where you want to store the reports (i.e. C:\temp)" 
write-host "Thank you." -ForegroundColor Green

# List all mailboxes
Write-host "Gathering mailboxes and their accesrights. This might take a minute, so please standby." -ForegroundColor Green
$Mailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Select-Object Identity, User, alias

# List accesrights except default MS accounts and output them to a txt file
$Mailboxes | Sort-Object Identity | ForEach-Object {
    Get-MailboxPermission -Identity $_.Identity | Select-Object Identity, user, accessrights | Sort-Object Identity |
    Where-Object {
        ($_.User -notlike ‘*NT AUTHORITY*’) -and
        ($_.User -notlike ‘*S-1-5-21-*’) -and
        ($_.User -notlike ‘*JitUsers*’) -and
        ($_.User -notlike ‘*Administrator*’) -and
        ($_.User -notlike ‘*PRDTSB*’) -and
        ($_.User -notlike ‘*EURPRD*’) -and
        ($_.User -notlike ‘*EURPRO*’) 
    }
} | Out-File "$outputpath\Shared mailboxes incl. accessrights.txt"

#Time to clean up 
Write-Host "Done. The connection to Office 365 will now close, and the file opened.
Thank you, and until next time." -ForegroundColor Green
Invoke-item "$outputpath\Shared mailboxes incl. accessrights.txt"
Get-pssession | Remove-pssession