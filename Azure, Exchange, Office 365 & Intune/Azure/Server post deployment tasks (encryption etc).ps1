<#
.SYNOPSIS
Script to perform some common post deployment tasks for an Azure VM.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V5
- Proper Azure Powershell module

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt, or line by line.
#>

#Variables
$KVRGname = 'CONTOSO'; 
$VMRGName = 'CONTOSO';
$vmName = 'CONTOSO-MGMT01';
$KeyVaultName = 'EncryptionVault01';
$KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $KVRGname;
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri;
$KeyVaultResourceId = $KeyVault.ResourceId;

# Check if VM already has Azure Disk encryption enabled
Get-AzVmDiskEncryptionStatus -ResourceGroupName $VMRGname -VMName $vmName

# Install & enable Azure disk encrpyption
Set-AzVMDiskEncryptionExtension -ResourceGroupName $VMRGname -VMName $vmName -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $KeyVaultResourceId;

# Disable Azure disk encrpyption
Disable-AzVMDiskEncryption -ResourceGroupName $VMRGName -VMName $vmName -VolumeType "all"

Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $VMRGName –EnabledForDiskEncryption

$servers = @()
$servers = get-azvm | select-object name

foreach ($server in $servers) {
    Enable-AzRecoveryServicesBackupProtection -ResourceGroupName "CONTOSO" -Name $server.Name -Policy $policy
}

$secrets = @()
$secrets = Import-Csv 'c:\temp\secrets.csv'

foreach ($secret in $secrets) {
    Remove-AzKeyVaultSecret -name $secret.secrets -VaultName 'EncryptionVault01' -Confirm
}

Get-AzVMExtension -VMName egvmndes01 -ResourceGroupName egrgp01 #| out-file c:\temp\extensionsDC02.txt -Force
$vmName = 'CONTOSO-mgmt01'
$vmResourceGroupName = 'CONTOSO'
$ExtensionName = 'MicrosoftMonitoringAgent'
$ExtensionPublisher = 'Microsoft.EnterpriseCloud.Monitoring'
$extensionType = 'MicrosoftMonitoringAgent'
$ExtenstionTypeHandlerversion = '1.0'

Set-AZVMExtension -VMName $vmName -ResourceGroupName $vmResourceGroupName -Name $ExtensionName -Publisher $ExtensionPublisher `
    -ExtensionType $extensionType -Location westeurope -TypeHandlerVersion $ExtenstionTypeHandlerversion
