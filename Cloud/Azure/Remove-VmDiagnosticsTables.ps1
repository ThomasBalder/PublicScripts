<#
.SYNOPSIS
Script to bulk remove Azure VM Diagnostics data.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Helderpinto: https://github.com/helderpinto/azure-wellarchitected-toolkit/blob/main/cost-optimization/diagnostics-extension-cleanup/Remove-VmDiagnosticsTables.ps1

.DESCRIPTION
For use with the other script to export/inventory the data: https://github.com/helderpinto/azure-wellarchitected-toolkit/tree/main/cost-optimization/diagnostics-extension-cleanup

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
-
- Run script in an elevated (administrator) Powershell prompt;
#>
param(
    [Parameter(Mandatory = $false)]
    [string] $Cloud = "AzureCloud",

    [Parameter(Mandatory = $true)]
    [string] $StorageAccountsCsvPath,

    [Parameter(Mandatory = $false)]
    [string] $TargetSubscriptionId
)

$DiagnosticsTablesPrefixes = @('SchemasTable', 'WADDiagnosticInfrastructureLogsTable', 'WADMetrics', 'WADPerformanceCountersTable', 'WADDirectoriesTable',
    'WadLogsTable', 'WADWindowsEventLogsTable', 'wad-iis-failedreqlogfiles', 'wad-iis-logfiles', 'LinuxSyslog', '$Metrics',
    'LinuxCpu', 'LinuxDisk', 'LinuxMemory')

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
                                
Write-Output "About to remove all the Diagnostics Storage tables defined in $StorageAccountsCsvPath from subscription $TargetSubscriptionId and tenant $($ctx.Tenant.TenantId) ($Cloud)..."
$continueInput = Read-Host "Continue (Y/N)?"

if ("Y", "y" -contains $continueInput) {

    $storageAccountsCsv = Import-Csv -Path $StorageAccountsCsvPath

    foreach ($saItem in $storageAccountsCsv) {

        if ([string]::IsNullOrEmpty($TargetSubscriptionId) -or $saItem.subscriptionId -eq $TargetSubscriptionId) {
            Write-Host "Removing tables from $($saItem.storageAccountName) storage account..."

            if ($saItem.subscriptionId -ne $ctx.Subscription.Id) {
                $ctx = Select-AzSubscription -SubscriptionId $saItem.subscriptionId
            }
        
            $sa = Get-AzStorageAccount -ResourceGroupName $saItem.resourceGroup -StorageAccountName $saItem.storageAccountName
        
            $tables = Get-AzStorageTable -Context $sa.Context
    
            foreach ($table in $tables) {
                foreach ($prefix in $DiagnosticsTablesPrefixes) {
                    if ($table.Name.StartsWith($prefix, [System.StringComparison]::InvariantCultureIgnoreCase)) {
                        Write-Output "Removing table $($table.Name)..."
                        Remove-AzStorageTable -Name $table.Name -Context $sa.Context -Force
                        break
                    }
                }
            }    
        }
    }
    
    Write-Output "DONE!"
}