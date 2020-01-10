$FixAutoMapping = 
Get-MailboxPermission -Identity sharedmailbox | Where-Object { $_.AccessRights -eq "FullAccess" -and $_.IsInherited -eq $false }$FixAutoMapping | Remove-MailboxPermission$FixAutoMapping | 
ForEach-Object { Add-MailboxPermission -Identity $_.Identity -User $_.User -AccessRights:FullAccess -AutoMapping $false }

