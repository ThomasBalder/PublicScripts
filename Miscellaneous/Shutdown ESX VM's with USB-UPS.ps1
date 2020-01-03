<#
.SYNOPSIS
Script to shutdown ESX VM's by with help of the APC powerchute agent connected to a UPS with USB (instead of network)
NOTE: this is just the script. How to setup/install this script is found here: https://www.phy2vir.com/esxi-host-shutdown-with-apc-ups-connected-via-usb/

.REQUIREMENTS
- A (APC) UPS connected via usb to your ESX host.
- PStools/PSEXec
- Powerchute business edition (http://www.apc.com/shop/us/en/categories/power/ups/ups-management/powerchute-business-edition/_/N-o29ysx)
- VMware vSphere PowerCLI (https://my.vmware.com/web/vmware/details?downloadGroup=PCLI550&productId=352)
-- prerequisites for this (i.e. .NET 2.0)
- Powershell (obviously)
- Seperate ESX admin account (assign admin role at the homepage of the host (not vCenter!), Actions -> Permissions > add user account + role)

.CHANGES
Script is altered from original with the following changes
- Layout (regions are prettier)
- Updated shutdown VMGuest for ESX 6.5 compatibility
- Added shutdown Powerchute agent VM before the Host shutdown command (left the original code for you to use if you want)
- Changed write-output message a bit
- Added synopsis etc.

.SOURCE / original author
Script was compiled from contributions by Alan Renouf and Patrick Terlisten
To create an encrypted password file, execute the following command
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File upssecurestring.txt (on the PCBE machine, with POSH ran as SYSTEM with PStools/PSEXec)

#>


<#region one time setup password
On the PCBE machine, open an elevated CMD, navigate to the PStools folder and run:
.\PSEXec.exe -s -i powershell 
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File upssecurestring.txt
Move the password file to the scripts folder
you can now close the CMD and POSH boxes
#>

#variables
$ScriptFolder = "C:\APC_Scripts"
$ESXUsername="apcups"
$ESXPassword=Get-Content $ScriptFolder\upssecurestring.txt | ConvertTo-SecureString
$ESXCredentials=New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $ESXUsername, $ESXPassword
$ESXSRVIP = "yourESXip" 
#Name of the VM where PCBE is installed
$Powerchute_Agent_VM="VMName"

#Add the VMware PowerCLI Snapin to the Powershell Environment and connect to the ESXi host
Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server $ESXSRVIP -Credential $ESXCredentials
 
#Get the ESXi Host object from the virtual infrastructure
$ESXVMHOST=Get-VMHost
 
# Set the amount of time to wait before assuming the remaining powered on guests are stuck or 
# cannot be shutdown because VMware tools are not installed.
$waittime = 120 #Seconds
 
# For each of the VMs on the ESXi host
Write-Output "VM Shut down sequence Started"
Foreach ($VM in ($ESXVMHOST | Get-VM))
{
 if ($VM.Name -eq $Powerchute_Agent_VM) 
 {
 Write-Output "Skipping $VM because it is the PowerChute Agent"
 }
 
 else
 {
 if ($VM.PowerState -eq "PoweredOn") 
 {
 $VM | Shutdown-VMGuest -Confirm:$false
 Write-Output "***** $VM is ON and will be shut down *****"
 }
 Else {Write-Output "!!!!!!!!! $VM is already switched OFF!!!!!!!!!!!"}
 }
 }
$Time = [math]::Round((Get-Date).TimeofDay.TotalSeconds)
do {
 # Wait for the VMs to be Shut down cleanly
 $timeleft = $waittime - $Newtime
# Get number of VMs still powered ON. Deduct the PCBE VM as it will not be shut down
 $numvms = ($ESXVMHOST | Get-VM | Where { $_.PowerState -eq "poweredOn" }).Count - 1
 Write-Output "Waiting for shut down of $numvms VMs or until $timeleft seconds"
 sleep 10.0 
 $Newtime = [math]::Round((Get-Date).TimeofDay.TotalSeconds) - $Time
 } until (($numvms) -eq 0 -or $Newtime -ge $waittime)
 
# Shut down the ESXi Hosts
Write-Output "Initiating shut down of the ESXi Hosts"
#Shutdown Powerchute agent VM
shutdown -s -f -t 10
$ESXVMHOST | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}
$finishtime = Get-Date -format "dd/MM/yyyy HH:mm:ss"
Write-Output "Shutdown Completed on $finishtime "
Disconnect-VIServer -Server $ESXSRVIP -Confirm:$false
