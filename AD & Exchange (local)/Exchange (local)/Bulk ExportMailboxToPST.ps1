<#
.SYNOPSIS
Script to (bulk) export mailboxes from local Exchange to PST files.
Can be used as part of a user termination script (i.e. https://github.com/ThomasBalder/PublicScripts/blob/master/AD%2C%20Exchange%2C%20Office%20365%20%26%20Intune/AD%20(local)/Disable-user%20(incl.%20O365).ps1)

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
- Imports the content from a simple txt file;
- Gives your admin account FullAccess permission on each mailbox found in the afore mentioned txt file;
- Exports the mailbox to a PST file.

.REQUIREMENTS
- Correct Exchange Powershell module;
- Correct/proper permissions on the Exchange environment & file share;
- Enough diskspace on the fileshare (obviously).

.INSTRUCTIONS
- Modify the variables below for your organization;
- Run script in an elevated (administrator) Exchange Powershell prompt on an Exchange server;
- If you only need this to work for one user (at a time), remove the "foreach" statement and the {}.
#>

#variables
$content = get-content "C:\Scripts\Aliases.txt"
$adminaccount = "youradminaccount"
$filepath = "\\sharedfolderlocation\folder1\folder2"

foreach ($user in $content)
{
Add-MailboxPermission -Identity $user -User $adminaccount -AccessRights FullAccess
New-MailboxExportRequest -Mailbox $user -FilePath "$filepath\$user Mailbox.pst"
}