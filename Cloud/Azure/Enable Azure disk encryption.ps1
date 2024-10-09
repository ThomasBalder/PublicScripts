<#
.SYNOPSIS
Script to enable Azure disk encryption.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Microsoft: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-windows#enable-encryption-on-an-existing-or-running-windows-vm

.DESCRIPTION 
Script to enable Azure disk encryption.

.REQUIREMENTS
- At least Powershell V5
- AzureAD Module (install with Install-Module AzureAD)

.INSTRUCTIONS
- Change variables where needed, and connect to Azure using Connect-AzureAD.
- Run script in an elevated (administrator) Powershell prompt;
#>

#Variables
$KVRGname = 'CONTOSO'; 
$VMRGName = 'CONTOSO';
$vmName = 'CONTOSO-VM01';
$KeyVaultName = 'EncryptionVault01';
$KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $KVRGname;
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri;
$KeyVaultResourceId = $KeyVault.ResourceId;

# Check if VM already has Azure Disk encryption enabled
Get-AzVmDiskEncryptionStatus -ResourceGroupName $VMRGname -VMName $vmName

# Install & enable Azure disk encrpyption for single server
Set-AzVMDiskEncryptionExtension -ResourceGroupName $VMRGname -VMName $vmName -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $KeyVaultResourceId;

# Install & enable Azure disk encrpyption for all servers
$servers = @()
$servers = get-azvm | Select-Object Name

foreach ($server in $servers) {
    Set-AzVMDiskEncryptionExtension -ResourceGroupName $VMRGname -VMName $server.Name -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $KeyVaultResourceId -Force
}
