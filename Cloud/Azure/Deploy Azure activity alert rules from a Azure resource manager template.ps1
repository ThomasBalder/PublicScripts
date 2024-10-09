<#
.SYNOPSIS
Script to deploy Azure activity alert rules from a Azure resource manager template.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Script to deploy Azure activity alert rules from a Azure resource manager template.
https://docs.microsoft.com/en-in/azure/azure-monitor/alerts/alerts-activity-log#powershell

.REQUIREMENTS
- At least Powershell V5
- Azure Powershell module

.INSTRUCTIONS
-
- Run script in an elevated (administrator) Powershell prompt;

#>
$resourcegroup = 'Contoso-ActivityLogs'
$templatelocation = 'C:\temp\Alert rules\Create policy assignment'

New-AzResourceGroupDeployment -ResourceGroupName $resourcegroup -TemplateFile $templatelocation\template.json
