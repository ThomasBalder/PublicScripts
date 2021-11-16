<#
.SYNOPSIS
Script to fix some known Azure services that are unquoted and not installed in C:\Windows.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
. Reference to find unquoted services that start automatically and are not installed in C:\Windows.
wmic service get name,pathname,displayname,startmode | findstr /i auto | findstr /i /v "C:\Windows\\" | findstr /i /v """
#>

Start-transcript 'C:\scripts\Logs\Configure unquoted Azure services.log'

#General variables
$Name = 'Imagepath'

#Guest Configuration Service 
$ServiceName = 'GCService'
$GuestAgentPath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\GCService'
$GuestAgentValue = Get-ItempropertyValue -Path $GuestAgentPath.PSPath -Name $Name
If (-NOT ($GuestAgentValue.contains('"'))) {
    Write-Host "Service $ServiceName is unquoted. Will try to fix it!"
    Set-ItemProperty -Path $GuestAgentPath.PSPath -name $name -Value "`"$GuestAgentValue`"" 
    $GuestAgentValue = Get-ItempropertyValue -Path $GuestAgentPath.PSPath -Name $Name
    Write-Host $GuestAgentValue.ImagePath
    Write-Host "This service needs to be changed manually before it can start properly." -ForegroundColor Yellow
    Write-Host "Please open the registry editor and change the value to '"C:\Packages\Plugins\Microsoft.GuestConfiguration.ConfigurationforWindows\1.29.33.0\dsc\GC\gc_service.exe" -k netsvcs'" -ForegroundColor Yellow
}
Else {
    Write-Host "Service $ServiceName is quoted, no action required." 
}

#RdAgent
$ServiceName = 'RdAgent'
$RDAgentPath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\RdAgent'
$RDAgentValue = Get-ItempropertyValue -Path $RDAgentPath.PSPath -Name $Name
If (-NOT ($RDAgentValue.contains('"'))) {
    Write-Host "Service $ServiceName is unquoted. Will try to fix it!"
    Set-ItemProperty -Path $RDAgentPath.PSPath -name $name -Value "`"$RDAgentValue`"" 
    $RDAgentValue = Get-ItempropertyValue -Path $RDAgentPath.PSPath -Name $Name
    Write-Host $RDAgentValue.ImagePath
    Restart-Service -Name $ServiceName
}
Else {
    Write-Host "Service $ServiceName is quoted, no action required." 
}

#VM Guest Health Agent
$ServiceName = 'vmGuestHealthAgent'
$vmGuestHealthAgentPath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\vmGuestHealthAgent'
$vmGuestHealthAgentValue = Get-ItempropertyValue -Path $vmGuestHealthAgentPath.PSPath -Name $Name
If (-NOT ($vmGuestHealthAgentValue.contains('"'))) {
    Write-Host "Service $ServiceName is unquoted. Will try to fix it!"
    Set-ItemProperty -Path $vmGuestHealthAgentPath.PSPath -name $name -Value "`"$vmGuestHealthAgentValue`"" 
    $vmGuestHealthAgentValue = Get-ItempropertyValue -Path $vmGuestHealthAgentPath.PSPath -Name $Name
    Write-Host $vmGuestHealthAgentValue.ImagePath
    Restart-Service -Name $ServiceName
}
Else {
    Write-Host "Service $ServiceName is quoted, no action required." 
}

#WindowsAzureGuestAgent
$ServiceName = 'WindowsAzureGuestAgent'
$WindowsAzureGuestAgentPath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WindowsAzureGuestAgent'
$WindowsAzureGuestAgentValue = Get-ItempropertyValue -Path $WindowsAzureGuestAgentPath.PSPath -Name $Name
If (-NOT ($WindowsAzureGuestAgentValue.contains('"'))) {
    Write-Host "Service $ServiceName is unquoted. Will try to fix it!"
    Set-ItemProperty -Path $WindowsAzureGuestAgentPath.PSPath -name $name -Value "`"$WindowsAzureGuestAgentValue`"" 
    $WindowsAzureGuestAgentValue = Get-ItempropertyValue -Path $WindowsAzureGuestAgentPath.PSPath -Name $Name
    Write-Host $WindowsAzureGuestAgentValue.ImagePath
    Restart-Service -Name $ServiceName
}
Else {
    Write-Host "Service $ServiceName is quoted, no action required." 
}

#Windows Azure Network Agent
$ServiceName = 'WindowsAzureNetAgentSvc'
$WindowsAzureNetAgentSvcPath = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WindowsAzureNetAgentSvc'
$WindowsAzureNetAgentSvcValue = Get-ItempropertyValue -Path $WindowsAzureNetAgentSvcPath.PSPath -Name $Name
If (-NOT ($WindowsAzureNetAgentSvcValue.contains('"'))) {
    Write-Host "Service $ServiceName is unquoted. Will try to fix it!"
    Set-ItemProperty -Path $WindowsAzureNetAgentSvcPath.PSPath -name $name -Value "`"$WindowsAzureNetAgentSvcValue`"" 
    $WindowsAzureNetAgentSvcValue = Get-ItempropertyValue -Path $WindowsAzureNetAgentSvcPath.PSPath -Name $Name
    Write-Host $WindowsAzureNetAgentSvcValue.ImagePath
    Restart-Service -Name $ServiceName
}
Else {
    Write-Host "Service $ServiceName is quoted, no action required." 
}

Stop-transcript