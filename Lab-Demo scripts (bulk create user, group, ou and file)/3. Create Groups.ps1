###########################################################  
# AUTHOR  : Marius / Hican - http://www.hican.nl - @hicannl   
# DATE    : 08-08-2012 
# EDIT    : 16-11-2012 
# CHANGES : Added functionality for duplicate OU names and 
#           changed the input file slightly because of this 
# COMMENT : This script does a bulk creation of Groups in 
#           Active Directory based on an input csv and the 
#           Active Directory Module.  
#           Don't forget to modify CSV name and location
# Usage    : Open script in ISE as admin an run from there. 
###########################################################  


Import-Module ActiveDirectory
#Import CSV
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition 
$newpath  = $path + "\3. Groups.csv"
$csv      = @()
$csv      = Import-Csv -Path $newpath

#Get Domain Base
$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }

#Loop through all items in the CSV
ForEach ($item In $csv)
{
  #Check if the OU exists
  $check = [ADSI]::Exists("LDAP://$($item.GroupLocation),$($searchbase)")
  
  If ($check -eq $True)
  {
    Try
    {
      #Check if the Group already exists
      $exists = Get-ADGroup $item.GroupName
      Write-Host "Group $($item.GroupName) already exists! Group creation skipped!"
    }
    Catch
    {
      #Create the group if it doesn't exist
      $create = New-ADGroup -Name $item.GroupName -GroupScope $item.GroupType -Path ($($item.GroupLocation)+","+$($searchbase))
      if (-not [string]::IsNullOrWhiteSpace($item.GroupMembers))
      {
      $create = Add-ADGroupMember -Identity $Item.GroupName -Members ($Item.GroupMembers)
      }
      if (-not [string]::IsNullOrWhiteSpace($item.GroupMembers2))
      {
      $create = Add-ADGroupMember -Identity $Item.GroupName -Members ($Item.GroupMembers2)
      }
	        if (-not [string]::IsNullOrWhiteSpace($item.GroupMembers3))
      {
      $create = Add-ADGroupMember -Identity $Item.GroupName -Members ($Item.GroupMembers3)
      }
      if (-not [string]::IsNullOrWhiteSpace($item.GroupMembers4))
      {
      $create = Add-ADGroupMember -Identity $Item.GroupName -Members ($Item.GroupMembers4)
      }
      #create the group if it doesn't exist with additional attribute
      #$create = New-ADGroup -Name $item.GroupName -GroupScope $item.GroupType -Path ($($item.GroupLocation)+","+$($searchbase)) -OtherAttributes @{'mail'=$item.Email} -ManagedBy $item.Managedby -otherattribute @{info=($item.notes)} -GroupCategory $item.GroupCategory
      Write-Host "Group $($item.GroupName) created!"
    }
  }
  Else
  {
    Write-Host "Target OU can't be found! Group creation skipped!"
  }
}