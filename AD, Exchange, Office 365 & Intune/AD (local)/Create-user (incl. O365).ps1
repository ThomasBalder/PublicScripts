<#
.SYNOPSIS
Script to create a user account in local AD and sync it to O365.
.AUTHOR Thomas Balder (inspired by others)

.Descritpion
- Creates a user in local AD;
- Adds the user to the AD-groups (specified from the $fromuser)
- Syncs tp AAD/Office 365;
- Checks if it's there and then:
-- Adds licenses (Intune en E3);
-- Creates the mailbox;
-- Sets the correct mailboxpermissions (lines 124+125)
-- Adds the user to the specified mail distribution groups
- Closes all Office 365 sessions
- Logs (and overwrites) the process

.Requirements
- At least Powershell V5;
- ActiveDirectory module (obviously);
- AzureAD module (can be installed with install-module AzureAD);
- ExchangeOnline module. (can be installed with the one-liner below):
Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
- Correct permissions on both AD and O365.

.Instructions
- Run script in an elevated (administrator) Powershell prompt on the DC that has the AAD sync tool installed;
- There are quite a few (generalized) functions & variables in this script that you might not use. 
-- Please read through the script and modify/delete where applicable.
-- Also note that sometimes it takes longer than two minutes to create the mailbox, so if the Accessrights assignment fails the first time
you'll have to repeat that step.
#>

#Start logging
Start-Transcript -Path c:\temp\User-Creation.txt -Force
Write-Host "The logs of this process are written to C:\temp\User-creation.txt" -ForegroundColor Magenta

#Import correct module
Import-Module ActiveDirectory 

#Connect to Office 365
Write-Host "Connecting to Office 365. Please log in with your administartor credentials." -ForegroundColor Yellow
Connect-AzureAD
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
. "$MFAExchangeModule" | out-Null
Connect-EXOPSSession 

#Clear screen
Clear-host

#Variables for the user etc.
Write-host "Please enter the first name (given name) for the User:" -ForegroundColor Yellow
Write-Host "For double names, you" -ForegroundColor Yellow -NoNewline;
Write-Host " don't " -foregroundcolor Red -NoNewline;
Write-Host 'need to use extra "".' -ForegroundColor Yellow 
Write-host "RIGHT: " -ForegroundColor Green -NoNewline
Write-host "George Bernard Shaw" -ForegroundColor Cyan
Write-host "WRONG: " -ForegroundColor Red -NoNewline
Write-host '"George Bernard" Shaw' -ForegroundColor Cyan
$Firstname = Read-Host
Write-host "Please enter the last name of the user:" -ForegroundColor Yellow
$Lastname = Read-Host 
$Name = "$Firstname` $Lastname"
Write-host "Please enter the username for the user:" -ForegroundColor Yellow
$ADName = Read-host 
Write-host "Enter a password for the user" -ForegroundColor Yellow
$password = Read-Host
Write-host "Enter a username from whom we copy the correct AD-groups" -ForegroundColor Yellow
$copyfrom = Read-Host 
$oupath = "OU=New Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"

#Create user in AD
Write-host "The useraccount is being created." -ForegroundColor Yellow
New-aduser -samaccountname $adname -UserPrincipalName "$adname@contoso.com" -name $Name -Givenname $Firstname -Surname $Lastname -DisplayName $Name `
    -AccountPassword (ConvertTo-SecureString $Password-AsPlainText -force) -PasswordNeverExpires $false -CannotChangePassword $false -path $oupath -Enabled $true

#Allow dial-in access (apparantly, this is not copied) 
Set-Aduser $adname -replace @{msnpallowdialin = $true }

#Add user to correct AD-groups
Write-host "The useraccount is created, and will now be added to the specified AD-groups." -ForegroundColor Green
Get-ADUser -Identity $copyfrom -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $adname

#Sync to AAD
Write-host "Now we're going to sync to Office 365." -ForegroundColor Green
Start-adsyncSynccycle -Policytype Delta

#Wait for the sync to complete
Write-host "Wait 90 seconds for the sync to complete." -ForegroundColor Yellow
Start-Sleep -seconds 90

#Region license variables
#Create objects for the licenses to be added to
$E3License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$EMSLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense

#Create variables for the licenses, and add them to the above created objects
$E3License.SkuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"
$EMSLicense.SkuId = "efccb6f7-5641-4e0e-bd10-b4976e1bf68e"
 
#Create a new object for the license objects 
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

#Add the license variables to the license object
$LicensesToAssign.AddLicenses = $E3License, $EMSLicense
#Endregion license variables

#Check if the user is present in O365
If ($null -eq $user) {
    Write-host "The useraccount is not yet present in Office 365, please waith a bit more." -ForegroundColor Magenta
    Start-Sleep -seconds 90
}
Else {
    Write-host "The useraccount is present in Office 365.
    Adding the licenses." -Foregroundcolor Green
    Set-AzureADUser -ObjectId $user.ObjectId -UsageLocation NL
    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $LicensesToAssign
}

#Wait a bit for the mailbox to be created
Write-host "The licenses have been added, now we have to wait until the mailbox has been created
 before we can set the correct accesrights." -ForegroundColor Green
Write-host "Wait two minutes." -ForegroundColor Yellow
Start-Sleep -seconds 120

#Set correct mailbox permissions/accessrights
Write-Host "The mailbox shoudl now be created. Let's assign the correct accessrights." -ForegroundColor Green
Add-MailboxPermission -Identity $ADName -User "user@contoso.com" -AccessRights FullAccess -Confirm:$false -AutoMapping $false
Add-MailboxPermission -Identity $ADName -User "user@contoso.com" -AccessRights FullAccess -Confirm:$false -AutoMapping $false

#Add the user to O365 distribution groups
Write-host "The correct accessrights on the mailbox are set, so now we can add the user to the correct email distribution groups." -ForegroundColor Green
Write-Host "Please enter the email distribution groups you want the user to be a member of. 
Seperate multiple groups with a ',' but without an extra space."-ForegroundColor Yellow 
Write-host "In example:" -ForegroundColor Yellow
Write-host "CORRECT: Everyone,Investment Team,Marketing" -ForegroundColor Green 
Write-host "INCORRECT: Everyone, Investment Team, Marketing" -ForegroundColor Red
[string[]] $distributiongroups = @()
$distributiongroups = READ-HOST 
$distributiongroups = $distributiongroups.Split(',')

foreach ($group in ($distributiongroups)) {
    Add-DistributionGroupMember -identity $group –Member "$adname" -Verbose
}

#Time to clean up
Write-Host "Everything is finished, so the connection to Office 365 is being closed." -ForegroundColor Green
Write-Host "Thank you, and until next time." -ForegroundColor Green
Get-pssession | Remove-pssession

Stop-Transcript

Notepad c:\temp\User-Creation.txt