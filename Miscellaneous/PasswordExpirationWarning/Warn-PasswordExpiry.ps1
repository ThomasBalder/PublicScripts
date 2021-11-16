<#
.SYNOPSIS
Script to send users an email when their password is about to expire. Can be run as scheduled task.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
#>

#Import AD Module
Import-Module ActiveDirectory

#Email Variables
$MailSender = "contoso@contoso.com"
$path = Split-Path -Path $MyInvocation.MyCommand.Path
$scriptName = $MyInvocation.MyCommand.Name
$prefix = $scriptname.replace(".ps1", "")

Try {
    Write-EventLog -LogName "Application" -Source $prefix -EventID 1 -EntryType Information -Message "Started."
}
Catch {
    New-EventLog –LogName Application –Source $prefix
    Write-Host "Script initialized, please restart."
    Break
}

$pwdfile = "$path\$scriptName"
$pwdfile = $pwdfile.Replace(".ps1", ".pwd")
if (!(Test-Path $pwdfile)) {
    Write-EventLog -LogName "Application" -Source $prefix -EventID 201 -EntryType Warning -Message "Passwordfile $pwdfile not found."
    $credential = Get-Credential -Message "Enter credentials for this script to run and mail from" -UserName $MailSender
    $credential.Password | ConvertFrom-SecureString | Set-Content $pwdfile
}
Write-Host "Reading password from $pwdfile"
$encrypted = Get-Content $pwdfile | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PsCredential($MailSender, $encrypted)

$SMTPServer = 'smtp.office365.com'
$Template = "$path\$scriptName"
$Template = $Template.Replace(".ps1", ".html")
if (!(Test-Path $Template)) {
    Write-EventLog -LogName "Application" -Source $prefix -EventID 301 -EntryType Warning -Message "Templatefile $Template not found."
    Write-Host "No template for email found ($Template)."
    exit
}
else {
    Write-Host "Reading template from $Template"
    $EmailTemplate = Get-Content $Template -Raw
}

#Find accounts that are enabled and have expiring passwords
Write-Host "Looking for expiring accounts"
$users = Get-ADUser -filter { Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0 -and (userPrincipalName -like '*@*') } `
    -Properties "Name", "userPrincipalName", "sAMAccountName", "givenName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Name", "userPrincipalName", "sAMAccountName", `
    "givenName", @{Name = "PasswordExpiry"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring() } }

#check password expiration date and send email on match
$WarningDays = 1, 3, 7
foreach ($user in $users) {
    foreach ($WarnDay in $WarningDays) {
        if ($user.PasswordExpiry -eq (get-date).adddays($WarnDay).ToLongDateString()) {
            Write-Host $user.name`t$Warnday
            $useraccount = $user.sAMAccountName
            Write-EventLog -LogName "Application" -Source $prefix -EventID 10 -EntryType Information -Message "User $useraccount expires in $WarnDay days."
            $EmailBody = $EmailTemplate
            $EmailBody = $Emailbody.Replace("[FIRST]", $user.givenName)
            $EmailBody = $Emailbody.Replace("[EMAIL]", $user.userPrincipalName)
            $EmailBody = $Emailbody.Replace("[ACCOUNT]", $user.sAMAccountName)
            $EmailBody = $Emailbody.Replace("[NAME]", $user.name)
            $EmailBody = $Emailbody.Replace("[DAYS]", $WarnDay)
            $EmailBody = $Emailbody.Replace("[EXPIRYDATE]", (get-date).adddays($WarnDay).ToLongDateString())
            Send-MailMessage -To $user.userPrincipalName -Bcc jschutte@ilionx.com -From no-reply@egeria.nl -SmtpServer $SMTPServer -Subject "Your password expires in $WarnDay days" -Body $EmailBody -BodyAsHTML -Port 587 -UseSSL -Credential $cred -Verbose
            #Send-MailMessage -To $user.userPrincipalName -From $MailSender -SmtpServer $SMTPServer -Subject "Your password expires in $WarnDay days" -Body $EmailBody -BodyAsHTML -Port 587 -UseSSL -Credential $cred -Verbose
        }
    }
}
Write-EventLog -LogName "Application" -Source $prefix -EventID 2 -EntryType Information -Message "Ended normally."
