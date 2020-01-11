<# 
.SYNOPSIS 
    Clone-Group
.DESCRIPTION 
    Clones group Members from Source to Target
.NOTES 
    Have both Source and Target group Distinguished Name at hand
.LINK 
#> 

#Set Source and Target Group Distinguished Name
$sourceGroup = [ADSI]"LDAP://OU=New Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"
$targetGroup = [ADSI]"LDAP://OU=New Users,OU=Managed Users,OU=Contoso,DC=contoso,DC=local"

"Source Group: $($sourceGroup.samAccountName)"
"Target Group: $($targetGroup.samAccountName)" 

"`nCloning Source Group to TargetGroup`n" 
  
#get Source members
foreach ($member in $sourceGroup.Member)
{
    Try
    {
        "Adding Member: $member"
        $targetGroup.add("LDAP://$($member)")
    }
    Catch
    {
        Write-Host "Error performing add action" -Fore DarkRed
    }

}