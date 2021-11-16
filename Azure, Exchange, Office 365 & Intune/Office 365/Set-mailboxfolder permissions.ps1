<#
.SYNOPSIS
Script (or rather multiple lines/snippets) to grant or remove permissions to specific folders (i.e. calendar) or meeting room mailboxes/

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
See .SYNOPSIS
- Depending on the languagepack the user has installed, "Calander" might have a different name (i.e. Agenda)
- Availabe accessrights:
- Owner — read, create, modify and delete all items and folders. Also this role allows manage items permissions;
- PublishingEditor — read, create, modify and delete items/subfolders;
- Editor — read, create, modify and delete items;
- PublishingAuthor — read, create all items/subfolders. You can modify and delete only items you create;
- Author — create and read items; edit and delete own items NonEditingAuthor – full read access and create items. You can delete only your own items;
- Reviewer — read-only;
- Contributor — create items and folders;
- AvailabilityOnly — read free/busy information from the calendar;
- LimitedDetails;
- None — no permissions to access folder and files.
- Source: https://theitbros.com/add-calendar-permissions-in-office-365-via-powershell/

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
Connect-AzureAD
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
. "$MFAExchangeModule" | out-Null
Connect-EXOPSSession 

#Set correct permissions for the shared mailbox
$Mailboxuser = Read-host -Prompt "Please enter the UPN for the primary user who needs to access the shared mailbox:"

# Full access meetingrooms
Write-host "Setting FullAccess rights on all meetingroom mailboxes."
Get-Mailbox | Where-Object { $_.resourcetype -eq "room" } | Add-MailboxPermission -user "$mailboxuser" -AccessRights FullAccess

# Add editor permissions for one user on -all- user mailboxes
Write-host "Setting Editor rights on -all- user mailboxes."
$Mailboxes = Get-Mailbox | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }  
ForEach ($Mailbox in $Mailboxes) { Add-mailboxfolderpermission -identity ($Mailbox.alias + ':\Calander') -user $mailboxuser -AccessRights Editor }

# Use this to get the folderpermissions
Get-mailboxfolderpermission -identity  rkleinherenbrink:\calendar 

# Use this to -add- folderpermissions
Add-mailboxfolderpermission -identity  johndoe:\calendar -user $mailboxuser

# Use this to remove folderpermissions
remove-mailboxfolderpermission -identity  johndoe:\calendar -user $mailboxuser

# Use this to -change- folderpermissions
Set-mailboxfolderpermission -identity johndoe:\Agenda -user $mailboxuser -AccessRights Editor