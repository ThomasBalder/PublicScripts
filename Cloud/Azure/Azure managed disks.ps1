<#
.SYNOPSIS
Script to convert VM with unmaged disk to one with managed disks.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Azure managed disks - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/convert-unmanaged-to-managed-disks#convert-single-instance-vms

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V5


.INSTRUCTIONS
-
- Run script in an elevated (administrator) Powershell prompt;

#>




# Stop & deallocate VM
$rgName = "contoso-rg01"
$vmName = "contoso-vm01"
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force

# Convert disks
ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $vmName

<# Or via Azure portal: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/convert-unmanaged-to-managed-disks#convert-using-the-azure-portal
Sign in to the Azure portal.
Select the VM from the list of VMs in the portal.
In the blade for the VM, select Disks from the menu.
At the top of the Disks blade, select Migrate to managed disks.
If your VM is in an availability set, there will be a warning on the Migrate to managed disks blade that you need to convert the availability set first. The warning should have a link you can click to convert the availability set. Once the availability set is converted or if your VM is not in an availability set, click Migrate to start the process of migrating your disks to managed disks.
The VM will be stopped and restarted after migration is complete.

# Afterwards, optional - Disk type aanpassen - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/convert-disk-storage#switch-managed-disks-from-one-disk-type-to-another
Sign in to the Azure portal.
Select the VM from the list of Virtual machines.
If the VM isn't stopped, select Stop at the top of the VM Overview pane, and wait for the VM to stop.
In the pane for the VM, select Disks from the menu.
Select the disk that you want to convert.
Select Configuration from the menu.
Change the Account type from the original disk type to the desired disk type.
Select Save, and close the disk pane.
The disk type conversion is instantaneous. You can start your VM after the conversion.
#>