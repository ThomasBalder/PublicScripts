<#
.SYNOPSIS
Script to bulk export Azure VM Diagnostics storage accounts.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Helderpinto: https://github.com/helderpinto/azure-wellarchitected-toolkit/blob/main/cost-optimization/diagnostics-extension-cleanup/Remove-VmDiagnosticsTables.ps1

.DESCRIPTION
For use with the other script to cleanup the data.
https://github.com/helderpinto/azure-wellarchitected-toolkit/tree/main/cost-optimization/diagnostics-extension-cleanup

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
-
- Run script in an elevated (administrator) Powershell prompt;
#>
param(
    [Parameter(Mandatory = $false)]
    [string] $Cloud = "AzureCloud"
)

$ctx = Get-AzContext
if (-not($ctx)) {
    Connect-AzAccount -Environment $Cloud
    $ctx = Get-AzContext
}
else {
    if ($ctx.Environment.Name -ne $Cloud) {
        Disconnect-AzAccount -ContextName $ctx.Name
        Connect-AzAccount -Environment $Cloud
        $ctx = Get-AzContext
    }
}

Write-Output "Generating the list of Storage Accounts used by the Azure Diagnostics extension (User: $($ctx.Account.Id); Tenant Id: $($ctx.Tenant.Id))"

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" } | ForEach-Object { "$($_.Id)"}

$queryText = @"
resources 
| where type =~ 'microsoft.compute/virtualmachines/extensions' and tostring(properties.type) in ('LinuxDiagnostic', 'IaaSDiagnostics')
| extend storageAccountName = iif(isempty(tostring(properties.settings.StorageAccount)),tostring(properties.settings.storageAccount),tostring(properties.settings.StorageAccount))
| project id, storageAccountName
| join kind=inner (
	resources
	| where type =~ 'microsoft.storage/storageAccounts'
	| project storageAccountName = name, resourceGroup, subscriptionId
) on storageAccountName
| summarize count() by storageAccountName, resourceGroup, subscriptionId
"@

$diagStorageAccounts = (Search-AzGraph -Query $queryText -Subscription $subscriptions).data

Write-Output "Found $($diagStorageAccounts.Count) storage accounts"

$csvExportPath = "diag-storageaccount-list-$Cloud.csv"
$diagStorageAccounts | Export-Csv -Path $csvExportPath -NoTypeInformation

Write-Output "Successfully exported diagnostics storage accounts details to $csvExportPath!"