#Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Currentuser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
.\CopyToPSPath.ps1 

#Import AzFilesHybrid module
Import-Module -name AzFilesHybrid

#Login with an Azure AD credential that has either storage account owner or contributer RBAC assignment
Connect-AzAccount

#Select the target subscription for the current session
Select-AzSubscription -SubscriptionId "3b72347a-2936-4661-9cb4-56f5df9309b4"

#Register the target storage account with your active directory environment under the target OU
join-AzStorageAccountForAuth -ResourceGroupName "SpinnakerTaders-RG01" -Name "spintradsa02" -DomainAccountType "ComputerAccount" -OrganizationalUnitName "CN=Computers,DC=SpinnakerTraders,DC=local"