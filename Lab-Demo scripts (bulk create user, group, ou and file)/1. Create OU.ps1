<#
.SYNOPSIS
Script to create OU in AD from a CSV File.

.AUTHOR 
Alexandre VIOT alexandreviot.net
---------------------------------
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V4
- Active directory module;
- Correct permissions on domani/AD.

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt on a DC or machine with RAST
- PS C:\scripts> & '.\1. CreateOU.ps1' -FileCSV '.\1. OU.csv';
#>

param([parameter(Mandatory=$true)] [String]$FileCSV)
$listOU=Import-CSV $FileCSV -Delimiter ","
ForEach($OU in $listOU){
 
try{
#Get Name and Path from the source file
$OUName = $OU.OUName
$OUPath = $OU.OUPath
 
#Display the name and path of the new OU
Write-Host -Foregroundcolor Yellow $OUName $OUPath
 
#Create OU
New-ADOrganizationalUnit -Name $OUName -Path $OUPath
 
#Display confirmation
Write-Host -ForegroundColor Green "OU $OUName created"
}catch{
 
Write-Host $error[0].Exception.Message
}
 
}