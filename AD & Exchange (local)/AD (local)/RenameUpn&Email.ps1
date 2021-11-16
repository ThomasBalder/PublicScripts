<#===========================================================================================================================
Script Name: RenameUpn&Email.ps1
Description: This Script Renames Active directory userprincipal,email,PrimarySMTPproxy name with your public domain name and also set the same Email address as UserPrincipal Name.
             Helpful Migrating Exchange to office365 or setting up Azure AD connect.
             Make sure you skip email part if email address in the AD is all correct.
      Inputs: Old DNS Suffix and Public domain name
      Outputs: The current UPN,email and proxy

Notes: Run as administrator
      Author: Jiten https://community.spiceworks.com/people/jitensh
Date Created: 27/07/2018
      Credits: 
Last Revised: 27/07/2018


** Instructions**
Open PowerShell as administrator and set execution policy as unrestricted.
Set-ExecutionPolicy unrestricted if required.Please replace $old suffix value with your current UPN

- Added lines to remove the old primary SMTP and add it back as an alias SMTP.
=============================================================================================================================#> 
If ( ! (Get-module ActiveDirectory )) {
    Import-Module ActiveDirectory
    Clear-Host
}
 
#$oldSuffix = You may also manually enter Old UPN suffix example under quotation 'domain.local'
$oldSuffix = ((Get-ADUser -filter * | Get-Random | Select-Object -First 1).UserPrincipalName).split('@')[1]

#Replace with the new suffix
Clear-Host
$newSuffix = Read-Host 'Enter Public domain name Ex: Contoso.com'
#Creating a New UPN suffix for the domain in Active Directory trust
If (-not((Get-ADForest).UPNsuffixes -match $newSuffix)) {

    "$newSuffix do not exists, Creating...." 
    Get-ADForest | Set-ADForest -UPNSuffixes @{add = "$newSuffix" }
}

#Replace with the OU you want to change suffixes for or Un-comment searchbase $ou if you want to set for specific OU users
#$ou = 'OU=xyx,DC=rim,DC=internal,DC=test'
$users = Get-ADUser -Filter { Enabled -eq $true } <#-SearchBase $ou #>  -Properties SamAccountName, UserPrincipalName, emailaddress, proxyaddresses
Foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    $id = $user.SamAccountName
    $newUpn = $upn.Replace($oldSuffix, $newSuffix) 
    Set-ADUser $id  -UserPrincipalName $newUpn
    ## Please remove below line if Emailaddress in AD is already correct
    Set-ADUser $id  -EmailAddress $newUpn 
    ### removing old primary SMTP and adding it as alias smtp
    $SMTP1 = "SMTP:"
    $SMTP2 = "smtp:"
    $SMTP1 = $SMTP1 + $Upn
    $SMTP2 = $SMTP2 + $Upn
    set-Aduser $id  -Remove @{ProxyAddresses = $SMTP1 }
    set-Aduser $id  -Add @{ProxyAddresses = $SMTP2 }

    ### Setting Primary SMTP
    $SMTP1 = "SMTP:"
    $SMTP3 = $SMTP1 + $newUpn
    set-Aduser $id  -add @{ProxyAddresses = $SMTP3 }
}

Clear-Host
$newU = (Get-ADUser -filter { Enabled -eq $true } <#-SearchBase $ou #>  -prop mail, proxyaddresses | Get-Random | Select-Object -First 1)
Write-Host 'The process has been completed' -ForegroundColor Yellow
Write-Host "`n The new UPN Looks like $($newU.userprincipalname) `n And the new Email looks like $($newU.mail) `n And the new Proxy looks like $($newU.proxyaddresses[0]) " -ForegroundColor Green