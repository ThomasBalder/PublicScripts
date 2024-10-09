<#
.SYNOPSIS
Script to export all Intune devices including OS, compliance state and Office 365 licenses.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
This script:
- Connects to Intune (using MSGraph), and creates exports all devices to a .csv with the following information:
-- devicename;
-- userDisplayName;
-- complianceState;
-- operatingSystem;
-- osVersion;
-- lastSyncDateTime;
- Connects to Office 365 and exports the E3 license information to a CSV file;
- Prompts to open reports.

.REQUIREMENTS
- At least Powershell V5;
- MS Grapgh powershell module (Install-Module -Name Microsoft.Graph.Intune) (https://www.powershellgallery.com/packages/Microsoft.Graph.Intune/);
- MSOnline module (Install-Module -Name MSOnline) (https://www.powershellgallery.com/packages/MSOnline/);
- Correct permissions on AAD/O365 and Intune.

.INSTRUCTIONS
- Change the variables on line 35. You can find your tenant name here: https://portal.office.com/adminportal#/Domains. It's the one preceeding .onmicrosoft.com.;
- Run script in an elevated (administrator) Powershell prompt.
#>

Start-Transcript "C:\temp\Office 365 license & Intune devices export.txt"

# Variables
$tenantname - "contoso.com" 

# Setup temp storage location for reports
$outputpath = Read-Host -Prompt "Please enter the path where you want to store the reports (i.e. C:\temp)" 
write-host "Thank you." -ForegroundColor Green

# Connect to Intune and Office 365
Write-Host "Connecting to Intune & Office 365. Please log in with your administrator credentials." -ForegroundColor Yellow
Connect-MSGraph 
Connect-MsolService

# Export all Intune devices and create report
Write-host "Now we're connected, let's export the devices from Intune." -ForegroundColor Green
Get-IntuneManagedDevice -Select devicename, userDisplayName, complianceState, operatingSystem, osVersion, lastSyncDateTime `
| Sort-Object userDisplayName | Export-Csv "$outputpath\IntuneDevices_$((Get-Date -format yyyy-MMM-dd).ToString()).csv" -Delimiter "," -NoTypeInformation -Encoding ASCII

# Export all Office 365 licenses and create report
write-host "The devices should now have been exported, so let's export the Office 365 licenses." -ForegroundColor Green
$members = Get-MsolUser -All | Where-Object { $_.licenses.AccountSkuID -match "$tenantname:ENTERPRISEPACK" } | Select-Object Displayname, licenses
foreach ($member in $members) {
    $Displayname = $member.DisplayName
    $output = new-object PSObject
    foreach ($group in $member.licenses) {
        $output | add-member NoteProperty "Displayname" -value $DisplayName -Force
        $output | add-member NoteProperty "Licensename" -value $group.AccountSkuId -Force
        $output | export-csv "$outputpath\Office 365 licenses.csv" -Append -NoTypeInformation -Encoding ASCII
    }
}

#Import CSV content to sort and append filename
Import-Csv "$outputpath\Office 365 licenses.csv" | Sort-Object DisplayName `
| export-csv "$outputpath\Office 365 licenses.csv_$((Get-Date -format yyyy-MMM-dd).ToString()).csv" -Append -NoTypeInformation -Encoding ASCII
Remove-Item "$outputpath\Office 365 licenses.csv"

#Time to clean up
Write-Host "Everything is finished, so the connection to Office 365 & Intune is being closed." -ForegroundColor Green
Write-Host "You will be prompted to open the files." -ForegroundColor Green
Write-Host "Thank you, and until next time." -ForegroundColor Green
Get-pssession | Remove-pssession

Stop-Transcript

#Open output file after execution
$Prompt = New-Object -ComObject wscript.shell
$UserInput = $Prompt.popup("Do you want to open output files?", `
    0, "Open Files", 4)
If ($UserInput -eq 6) {
    Invoke-Item "$outputpath\Office 365 licenses.csv_$((Get-Date -format yyyy-MMM-dd).ToString()).csv"
    Invoke-Item "$outputpath\IntuneDevices_$((Get-Date -format yyyy-MMM-dd).ToString()).csv"
    Invoke-Item "C:\temp\Office 365 license & Intune devices export.txt"
}