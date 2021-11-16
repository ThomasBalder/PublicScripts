<#
.SYNOPSIS
Script to modify a user in AD & Office 365. Useful for user-termination.

.AUTHOR 
Thomas Balder (inspired by others).
https://github.com/ThomasBalder/PublicScripts

.DESCRIPTION
- Appends the displayname with "(shared)";
- Removes user from all local AD-groups;
- Moves the user to a dedicated disabled users OU;
- Resets the password to a random string;
- Disables the account;
- Syncs the changes to O365 with ADSync;
- Checks if the user has permissions on other mailboxes (both user and shared), and if so removes them;
- Checks if the user is a member of O365 distribution groups, and removes the user from them;
- Converts the mailbox to a shared mailbox;
- Removes the Office 365 & Intune licenses;
- Gives a given user FullAccess permissions on the shared mailbox;
- Closes/removes all cloud-sessions;
- Creates (and overwrites) a logfile of this whole proces.

.REQUIREMENTS
- At least Powershell V5;
- ActiveDirectory module (obviously);
- AzureAD module (can be installed with install-module AzureAD);
- ExchangeOnline module. (can be installed with the one-liner below):
Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
- Correct permissions on both AD and O365.

.INSTRUCTIONS
- Modify  the variables from line 38 and line 96 (displayname) for your own organization;
- Run script in an elevated (administrator) Powershell prompt on the DC that has the AAD sync tool installed.
#>


function Test-IsAdministrator {
    <#
    .Synopsis
        Tests if the user is an administrator
    .Description
        Returns true if a user is an administrator, false if the user is not an administrator        
    .Example
        Test-IsAdministrator
    #>   
    
    param() 
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
} #end function Test-IsAdministrator

# Check if session started as UAC Admin
If (-not (Test-IsAdministrator)) { Write-Output "Admin rights are required for this script. Please open a Administrator Powershell prompt and rerun the script." ; exit }

#General variables
$SourceOU = (Get-ADUser -Identity $loginname).distinguishedName
$TargetOU = "OU=Terminated Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"

#Start logging
Start-Transcript -Path c:\temp\User-termination.log -Force
Write-Host "The logs of this process are written to C:\temp\User-termination.txt" -ForegroundColor Magenta

#region password randomizer
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs = ""
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString) {
    $characterArray = $inputString.ToCharArray()
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length
    $outputString = -join $scrambledStringArray
    return $outputString
}
#Password Parameters
$password = Get-RandomCharacters -length 3 -characters "abcdefghiklmnoprstuvwxyz"
$password += Get-RandomCharacters -length 3 -characters "ABCDEFGHKLMNOPRSTUVWXYZ"
$password += Get-RandomCharacters -length 3 -characters "1234567890"
$password += Get-RandomCharacters -length 3 -characters "!§$%&/()=?}][{@#*+"

$password = Scramble-String $password
#endregion

#Import AD module (might not be needed)
Import-Module ActiveDirectory 

#Connect to O365
Write-Host "Connecting to Office 365. Please log in with your administartor credentials." -ForegroundColor Yellow
Connect-AzureAD
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
. "$MFAExchangeModule" | out-Null
Connect-EXOPSSession 

#Clear screen
Clear-host

#Variabeles for the user
Write-host "Please enter the 'user logon name' (not UPN) for the user:" -ForegroundColor Yellow
$loginname = Read-host  
$upnsuffix = ((Get-ADUser $loginname | Get-Random | Select-Object -First 1).UserPrincipalName).split('@')[1]
$upn = "$loginname@$upnsuffix"

#Remove user from local AD-groups
Write-host "Thank you. Moving on to the next step.
The user is now removed from all AD-groups." -ForegroundColor Green
$ADgroups = Get-ADPrincipalGroupMembership -Identity $loginname | Where-Object { $_.Name -ne "Domain Users" } 
Remove-ADPrincipalGroupMembership -Identity  $loginname -MemberOf $ADgroups -Confirm:$false

#Append displayname
Write-host "The displayname has been changed." -ForegroundColor Green
Get-ADUser $loginname  -Properties DisplayName |
ForEach-Object {
    Set-ADUser -Identity $_ -DisplayName "$($_.DisplayName) (Shared)"
}

#Reset password
Write-host "The password is reset to a random string." -ForegroundColor Green
set-adaccountpassword -Identity $loginname  -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

#Disable the account
Write-host "The useraccount is now disabled." -ForegroundColor Green
Set-ADUser $loginname -Enabled $false

#Move the account to the terminated-users ou
Write-host "The useraccount is now moved to the terminated-users OU." -ForegroundColor Green
Move-ADObject -Identity $SourceOU -TargetPath $TargetOU

#Sync the changes to Office 365
Write-host "Now we're going to sync the changes to Office 365, and wait 90 seconds for the changes to be synced." -ForegroundColor Green
Start-adsyncSynccycle -Policytype Delta
Start-Sleep -seconds 90

#Remove the user from O365 distribution groups
Write-host "Time to move on. 
The user is now being removed from the Office 365 distribution groups." -ForegroundColor Green
Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember $_.Name | ForEach-Object { $_.PrimarySmtpAddress }) -contains "$upn" } `
| Remove-DistributionGroupMember -Member "$upn" -Confirm:$false

#Check which mailboxes the user has accesrights, and remove them
Write-host "Now we're going to check if the user has accessrights on other mailboxes, and if so, removes them.
This might take a minute, so please be patient." -ForegroundColor Green
$mailboxes = get-mailbox | Get-MailboxPermission -User $upn
foreach ($mb in $mailboxes) {
    $access = get-mailboxpermission $mb.identity -user $upn
    Remove-MailboxPermission -Identity $mb.Identity -user $upn -accessRights $access.accessrights -confirm:$false
}

#Convert the user mailbox to a shared mailbox
Write-host "The user mailbox is now being converted to a shared mailbox." -ForegroundColor Green
Set-Mailbox "$upn" -Type Shared

#Set correct permissions for the shared mailbox
Write-Host "The mailbox has been converted, time to set the correct permissions" -ForegroundColor Green
Write-host "Please enter the UPN for the primary user who needs to access the shared mailbox:" -ForegroundColor Yellow
$Mailboxuser = Read-host 
Add-MailboxPermission -Identity $upn -User "$mailboxuser" -AccessRights FullAccess -Confirm:$false -AutoMapping $True

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

#Create an array to define which licenses should be added (none)
$LicensesToAssign.AddLicenses = @()

#Create a variable for the licenses that should be removed
$LicensesToAssign.RemoveLicenses = $E3License.SkuId, $EMSLicense.SkuId

$user = Get-AzureADUser -SearchString $loginname
#Endregion license variables

#(Finally) remove the Office and Intune licenses 
Write-host "The licenses are being removed." -ForegroundColor Green
Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $LicensesToAssign

#Time to clean up
Write-Host "Everything is finished, so the connection to Office 365 is being closed." -ForegroundColor Green
Write-Host "Notepad wil open with the logfile, so you can check for errors." -ForegroundColor Green
Write-Host "Thank you, and until next time." -ForegroundColor Green
Get-pssession | Remove-pssession

Stop-Transcript

notepad c:\temp\User-termination.txt