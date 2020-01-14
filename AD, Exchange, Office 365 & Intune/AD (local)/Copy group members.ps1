<#
.SYNOPSIS
Small script to copy ADP-group members from one group to another.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
See .SYNOPSIS.

.REQUIREMENTS
- At least Powershell v3 (I think);
- ActiveDirectory Module;
- Proper permission on ActiveDirectory

.INSTRUCTIONS
- Change variables on line 23 & 24;
- Run script in an elevated (administrator) Powershell prompt on a DC.
#>

#Set Source and Target Group Distinguished Name
$sourceGroup = [ADSI]"LDAP://OU=New Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"
$targetGroup = [ADSI]"LDAP://OU=New Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"

"Source Group: $($sourceGroup.samAccountName)"
"Target Group: $($targetGroup.samAccountName)" 

"`nCloning Source Group to TargetGroup`n" 
  
#get Source members
foreach ($member in $sourceGroup.Member) {
    Try {
        "Adding Member: $member"
        $targetGroup.add("LDAP://$($member)")
    }
    Catch {
        Write-Host "Error performing add action" -Fore DarkRed
    }

}