<#
.SYNOPSIS 
Small script to send bulk emails. Supports Office 365. 
Don't forget to edit the $mailvariables on line 20.
#>

#enter credentials
Write-Host enter the credentials from the account you want to send the mails from (i.e. your own) -ForegroundColor Yellow
$Credential = (Get-Credential)

Write-Host Thank you. The emails shoud be sent. -ForegroundColor Green

#define settings 
$scriptSettings = @{
    NumberOfEmails    = 10
    TimeBetweenEmails = 2 #in seconds
}

#define mailvariables
$mailvariables = @{
    From       = "tintin@mydomain.com"
    To         = "ahaddock@anotherdomain.com"
    Subject    = "Test mail flow"
    SmtpServer = "smtp.office365.com"
    Port       = "587"
    Body       = "Email number $i"
}

#do the actual work
For ($i = 1; $i -le $scriptSettings.NumberOfEmails; $i++) {
    try {
        Send-MailMessage @mailvariables -UseSSL -Credential $Credential
    }   
    catch {
        "Error sending email $i" 
    }
    Start-Sleep -Seconds $scriptSettings.TimeBetweenEmails
} 

#end