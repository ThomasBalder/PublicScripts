#Global configurations
$Global:ObjectAuditing = $false
$Global:ExchangeAuditing = $false
$Global:AdfsAuditing = $false
$Global:isAdvancedAuditingOk = $false
$Global:isNtlmAuditingOk = $false
$Global:isRootCertificatesOk = $false
$Global:isPortalConnOk = $false
$Global:isSensorAPIConnOk = $false
$Global:DeletedObjPermission = $false
$Global:isNormalUser = $false
$Global:isGMSA = $false
$Global:GmsaPWRet = $false
$Global:NNR_RDP = $false
$Global:NNR_NTLM = $false
$Global:NNR_NetBIOS = $false
$Global:MachineType = "N\A"
$Global:appDisplayName = "N\A"
$Global:appVersion = "N\A"
$Global:SensorVersion = "N\A"
$Global:isRadiusListen = $false
$Global:isPowerSchemeOk = $false
$Global:Domain = Get-ADDomain 
$Global:Capturing_Comp = ""
$Global:Export_Folder_Path = Read-Host -Prompt "Please enter path for MDI_Export_Folder"
$Global:MDI_User_sAMAccountName = Read-Host -Prompt "Please Enter MDI Directory services User sAMAccountName, if the user is gMSA, type the sAMAccountName without $"
$Global:NNR_Machine_IP = Read-Host -Prompt "Please enter remote machine IP (to test active resolution)"
$Global:NNR_MAchine_Name = Read-Host -Prompt "Please enter remote machine NetBios Name (NotFQDN!) (to test active resolution)"

[string]$Global:WorkspaceName = Read-Host -Prompt "Please enter workspace name (without suffix)"
$Global:Is_Proxy_Enabled = Read-Host -Prompt "Please enter Y if proxy is enabled on the machine or you are using proxy for MDI sensor traffic"

if($Is_Proxy_Enabled -eq 'Y' -or $Is_Proxy_Enabled -eq 'y')
{
    $Is_Proxy_Enabled = 1
    $Global:ProxyServer =  Read-Host -Prompt "please enter proxy server IP and port (example : 192.168.0.207:80)"
    [string]$Global:ProxyUserName = Read-Host -Prompt "Please enter proxy user full UPN name"
    [string]$Global:ProxyUserPassword = Read-Host -Prompt 'Please enter proxy user''s password'
}

New-Item -Path $Export_Folder_Path -Name MDI_Export_Folder -ItemType Directory -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name WFP -ItemType Directory -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name MSINFO -ItemType Directory -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name Network_Settings.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name Proxy_Connections_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name Certs_SSL_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name Auditing_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name VM_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name DSA_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name NNR_Checks.txt -ItemType File -Force | out-null
New-Item -Path "$($Export_Folder_Path)\MDI_Export_Folder" -Name Tasks.txt -ItemType File -Force | out-null

#Get OS build
$Global:OS_Version = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\" -Name ProductName ).ProductName
"Machine OS version is: $($OS_Version)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
($Global:Sensor_PID = (Get-Process -ProcessName Microsoft.Tri.Sensor).Id) | out-null

if ([string]::IsNullOrWhiteSpace($Global:Sensor_PID) -ne $True){

    "Sensor PID is: $($Sensor_PID)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
    $Global:Sensor_PID_Found = $Sensor_PID
    $Global:Sensor_Process_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"

}
else{
    $Global:Sensor_PID = ""
    $Global:Sensor_PID_Found = "No Sensor Process was found"
    "No Sensor Process was found" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
    $Global:Sensor_Process_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"

}

    


#Functions Implementation
function Export-Logs
{
    # Read sensor installation path - new
    $Global:MDI_Installation_Path = Get-CimInstance -ClassName Win32_Service -Filter "name='AATPSensor'" | select PathName

    if ([string]::IsNullOrWhiteSpace($Global:MDI_Installation_Path) -ne $True)
    {
        $Global:MDI_Installation_Path  = $MDI_Installation_Path.PathName.Substring(1, $MDI_Installation_Path.PathName.indexOf("\Microsoft.Tri.Sensor.exe"))
        [Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
        $Compression = [System.IO.Compression.CompressionLevel]::Optimal
        $IncludeBaseDirectory = $false
        # Set Source folder
        $Source = "$($MDI_Installation_Path)\Logs"
        # Set destination Folder
        $Destination = "$($Export_Folder_Path)\MDI_Export_Folder\MDI_Sensors_Logs.zip"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($Source,$Destination,$Compression,$IncludeBaseDirectory)
        $Global:existingSensor = $true
        $Global:SensorLogsCollected = "Collected"
        $Global:SensorLogsURL = "<a href='MDI_Sensors_Logs.zip'>Sensor Logs</a>"
    }
    else
    {
        $Global:existingSensor = $false
        $Global:SensorLogsCollected = "No Sensor Installation Folders Found"
        $Global:SensorLogsURL = ""
    } 
  
}

function Get-RadiusStatus
{   
$Sensor_PID_From_Netstat = @(netstat -noa | findstr -i "0:1813 ")
$Sensor_PID_From_Netstat = ($Sensor_PID_From_Netstat -split ' ')[53]

  if($Sensor_PID_From_Netstat -eq $Sensor_PID -and $Sensor_PID -ne $null)
  {
   "The Sensor process PID $($Sensor_PID) is listening successefully on port 1813!" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
   $Global:isRadiusListen = $true
  }
  else
  {
    "The Sensor process $($Sensor_PID) is not listening  on port 1813!" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
  }
}

function Get-GPO
{
    $Destination = "$($Export_Folder_Path)\MDI_Export_Folder\gpresult.htm"
    gpresult /h $Destination
}

function Get-DeletedObjectsPermissions
{
    $DC_ACLs = dsacls "CN=Deleted Objects,$($Domain.DistinguishedName)" /A        
    $New_DC_ACLs = ($DC_ACLs | findstr Allow)
    $New_DC_ACLs.ToString()
    $New_DC_ACLs = $New_DC_ACLs.Replace("\","")

    "###############################################################################################"| Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
   
    if ([string]::IsNullOrWhiteSpace($Global:MDI_User_sAMAccountName) -ne $True)
    {
        if($New_DC_ACLs -match $MDI_User_sAMAccountName) 
        {
            "The MDI directory services user $($MDI_User_sAMAccountName) is permitted to access deleted objects container" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
            $Global:DeletedObjPermission = $true
        }
        else
        {
            "The MDI directory services user $($MDI_User_sAMAccountName) is not permitted to access deleted objects container" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
        }
    }
    else
    {
        "The MDI directory services user typed is not valid" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append  
    }

    "Full Deleted Objects ACLs:"| Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
    $DC_ACLs | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
    "###############################################################################################"| Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
}

function Get-MDIUserPermissions
{
    $MDI_User_Object = Get-ADObject -Filter 'Name -eq $MDI_User_sAMAccountName'
    if ($MDI_User_Object.ObjectClass -eq "user")
    {
        "The MDI directory services user $($MDI_User_sAMAccountName) object class is: user" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
        $Global:isNormalUser = $true
    }
    elseif($MDI_User_Object.ObjectClass -eq "msDS-GroupManagedServiceAccount")
    {
        "The MDI directory services user $($MDI_User_sAMAccountName) object class is: msDS-GroupManagedServiceAccount (gMSA)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
        $Global:isGMSA = $true
        if((Test-ADServiceAccount  $MDI_User_sAMAccountName) -eq "True")
        {
            "The MDI directory services user $($MDI_User_sAMAccountName) (gMSA user) can be used from this machine" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
            $Global:GmsaPWRet = $true
        }
        else
        {
            "This machine is not allowed to retrive MDI directory services user $MDI_User_sAMAccountName (gMSA user) password" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -append
        }
    }
    else
    {
    "The MDI directory services user typed is not valid" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\DSA_Checks.txt" -Append
    }
}

function Get-NNRStatus
{
    #NetBios
    if ([string]::IsNullOrWhiteSpace($Global:NNR_MAchine_Name) -ne $True)
    {
        $nbtstat = nbtstat -A $Global:NNR_Machine_IP
        $computerName = ''
        foreach ($line in $nbtStat)
        {
            if ($line -match '^\s*([^<\s]+)\s*<00>\s*UNIQUE')
            {
                $computerName = $matches[1]
                break
            }
        }
        if($computerName -eq $Global:NNR_MAchine_Name)
        {
            "NetBIOS resolving is working for $($NNR_MAchine_Name)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
            $Global:NNR_NetBIOS = $true
        }
        else
        {
            "NetBIOS resolving is not working for $($NNR_MAchine_Name)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
        }
     }
    else
    {
       "Entered NETBIOS Machine Name is not valid" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append     
    }
    
    
         
    #RDP port

    if ([string]::IsNullOrWhiteSpace($Global:NNR_Machine_IP) -ne $True)
    {
        $Test_RDP_Connection = 0
        $Test_RDP_Connection = New-Object System.Net.Sockets.TcpClient($Global:NNR_Machine_IP, 3389)
        if($Test_RDP_Connection.Connected -eq "True")
        {
            "RDP port is working for $($Global:NNR_Machine_IP)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
            $Global:NNR_RDP = $true
        }
        else
        {
            "RDP port is not working for $($Global:NNR_Machine_IP)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
        }
        $Test_RDP_Connection.Dispose()
    }
     else
    {
       "Entered IP Address is not valid" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append     
    }
        

    if ([string]::IsNullOrWhiteSpace($Global:NNR_Machine_IP) -ne $True)
    {
        #RPC NTLM port
        $Test_RPC_NTLM_Connection = 0
        $Test_RPC_NTLM_Connection = New-Object System.Net.Sockets.TcpClient($Global:NNR_Machine_IP, 135)
        if($Test_RPC_NTLM_Connection.Connected -eq "True")
        {
            "RPC_NTLM port is working for $($Global:NNR_Machine_IP)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
            $Global:NNR_NTLM = $true
        }
        else
        {
            "RPC_NTLM port is not working for $($Global:NNR_Machine_IP)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append
        }
        $Test_RPC_NTLM_Connection.Dispose()
    }
     else
    {
       "Entered IP Address is not valid" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\NNR_Checks.txt" -append     
    }    
}

# Get-ConnectionsStatus
function Get-ConnectionsStatus
{
    $Is_Proxy_Enabled_On_Machine_Internet = (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable").ProxyEnable

    if ($Is_Proxy_Enabled -eq 1)
    {
        "Proxy is enabled for MDI sensor and customer have confirmed it" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }
    if ($Is_Proxy_Enabled -ne 1)
    {
        "Customer have confirmed that proxy in not enabled for MDI sensor" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }
    
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append

    if ($Is_Proxy_Enabled_On_Machine_Internet -eq 1)
    {
        "Proxy is enabled on machine registry Internet configurations (Checking Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings -> ProxyEnable)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }
    if ($Is_Proxy_Enabled_On_Machine_Internet -ne 1)
    {
        "Proxy is not enabled on machine registry Internet configurations (Checking Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings -> ProxyEnable)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }
    
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    "" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    "Proxy Configuration on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    "" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    
	bitsadmin /util /getieproxy localsystem | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
	bitsadmin /util /getieproxy networkservice | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    bitsadmin /util /getieproxy localservice | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    netsh winhttp show proxy | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    "Testing Connection to MDI Portal and API" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    "" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append

    if($Is_Proxy_Enabled -eq 1)
    {
        # Convert to SecureString
        [securestring]$secStringPassword = ConvertTo-SecureString $ProxyUserPassword -AsPlainText -Force
        [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($ProxyUserName, $secStringPassword)
        $PortalWebResponse = 0
        $PortalWebResponse = try 
        { 
            (Invoke-WebRequest -Uri https://$($WorkspaceName).atp.azure.com -UseBasicParsing -Proxy http://$ProxyServer -ProxyCredential $credObject).BaseResponse
        } 
        catch [System.Net.WebException] 
        { 
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            $_.Exception.Response 
        }

    $SensorApiResponse = 0
    $SensorApiResponse = try 
    { 
        (Invoke-WebRequest -Uri https://$($WorkspaceName)sensorapi.atp.azure.com -UseBasicParsing -Proxy http://$ProxyServer -ProxyCredential $credObject).BaseResponse
    } catch [System.Net.WebException] 
    { 
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        $_.Exception.Response 
    } 

    if($PortalWebResponse.StatusCode -eq "200")  
    {
         "Portal Connection works !" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
         $Global:isPortalConnOk = $true
    }
    else
    {
        "Portal connection error: $($PortalWebResponse.StatusDescription)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }
    if ($SensorApiResponse.StatusCode -eq "ServiceUnavailable")
    {
         "SensorApi Connection works !" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
         $Global:isSensorAPIConnOk = $true

    }
    else
    {
        "Sensor connection error: $($SensorApiResponse.StatusDescription)"  | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
    }

}

    if($Is_Proxy_Enabled -ne 1)
    {
        $PortalWebResponse = 0
        $PortalWebResponse = try 
        { 
            (Invoke-WebRequest -Uri https://$($WorkspaceName).atp.azure.com -UseBasicParsing).BaseResponse
        } catch [System.Net.WebException] 
        { 
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            $_.Exception.Response 
        } 
        $SensorApiResponse = 0
        $SensorApiResponse = try 
        { 
            (Invoke-WebRequest -Uri https://$($WorkspaceName)sensorapi.atp.azure.com -UseBasicParsing).BaseResponse
        } catch [System.Net.WebException] 
        { 
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            $_.Exception.Response 
        } 
        if($PortalWebResponse.StatusCode -eq "200")  
        {
            "Portal Connection works !" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
            $Global:isPortalConnOk = $true
        }
        else
        {
            "Portal connection error: $($PortalWebResponse.StatusDescription)" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
        }
        if ($SensorApiResponse.StatusCode -eq "ServiceUnavailable")
        {
            "SensorApi Connection works !" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
            $Global:isSensorAPIConnOk = $true
        }
        else
        {
            "Sensor connection error:$($SensorApiResponse.StatusDescription)"  | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Proxy_Connections_Checks.txt" -append
        }
    }
}

function Get-mdiPowerScheme 
{
    $details = cmd.exe /c %windir%\system32\powercfg.exe /getactivescheme
    if ($details -match 'Power Scheme GUID:\s+(?<guid>[a-fA-F0-9]{8}[-]?([a-fA-F0-9]{4}[-]?){3}[a-fA-F0-9]{12})\s+\((?<name>.*)\)') 
    {
        $Global:isPowerSchemeOk = $true
        "Server meets power requirement of MDI, Power Option is set to High Performance" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
    } 
    else
    {
        $Global:isPowerSchemeOk = $false
        "Server does NOT meet power requirement of MDI, Power Option is NOT set to High Performance" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
    }
}


function Get-mdiAdvancedAuditing 
{
    $expectedAuditing = @'
    Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Setting Value
    System,Security System Extension,{0CCE9211-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Distribution Group Management,{0CCE9238-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Security Group Management,{0CCE9237-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Computer Account Management,{0CCE9236-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,User Account Management,{0CCE9235-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Directory Service Access,{0CCE923B-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Directory Service Changes,{0CCE923C-69AE-11D9-BED3-505054503030},Success and Failure,3
    System,Credential Validation,{0CCE923F-69AE-11D9-BED3-505054503030},Success and Failure,3
'@ | ConvertFrom-Csv
    
    $properties = ($expectedAuditing | Get-Member -MemberType NoteProperty).Name
    $localTempFile = 'mdi-{0}.csv' -f [guid]::NewGuid().Guid
    $path = "$($Export_Folder_Path)\MDI_Export_Folder\$($localTempFile)"
    auditpol.exe /backup /file:$path
    $output = Get-Content -Path $path
    $advancedAuditing = $output | ConvertFrom-Csv | Where-Object {$_.Subcategory -in ('Directory Service Changes','Security System Extension', 'Distribution Group Management', 'Security Group Management','Computer Account Management', 'User Account Management', 'Directory Service Access', 'Credential Validation')} | Select-Object -Property $properties
    $compareParams = @{
        ReferenceObject  = $expectedAuditing
        DifferenceObject = $advancedAuditing
        Property         = $properties
    }
    $Global:isAdvancedAuditingOk = $null -eq (Compare-Object @compareParams)
    if ($Global:isAdvancedAuditingOk)
    {
        "Advanced Auditing is configured on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $advancedAuditing| Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    } else 
    {
        "Advanced Auditing is NOT configured on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $advancedAuditing| Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    Remove-Item -Path $path -Force
}

function Get-mdiNtlmAuditing 
{
   $expectedRegistrySet = @(
        'System\CurrentControlSet\Control\Lsa\MSV1_0,AuditReceivingNTLMTraffic,2',
        'System\CurrentControlSet\Control\Lsa\MSV1_0,RestrictSendingNTLMTraffic,1',
        'System\CurrentControlSet\Services\Netlogon\Parameters,AuditNTLMInDomain,7')

    $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey("LocalMachine", "Registry64")
    $details = foreach ($reg in $expectedRegistrySet) {
        $regKeyPath, $regValue, $expectedValue = $reg -split ','
        $regKey = $hklm.OpenSubKey($regKeyPath)
        $value = $regKey.GetValue($regValue)
        [pscustomobject]@{
            regKey        = '{0}\{1}' -f $regKeyPath, $regValue
            value         = $value
            expectedValue = $expectedValue
        }
    }
    $hklm.Close()
    $Global:isNtlmAuditingOk = @($details | Where-Object { $_.value -ne $_.expectedValue }).Count -eq 0
    $details          = $details | Select-Object regKey, value

    if ($Global:isNtlmAuditingOk)
    {
        "NTLM Auditing is configured on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -appen
    } else 
    {
        "NTLM Auditing is NOT configured on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
}

function Get-mdiCertReadiness 
{    
    $expectedRootCertificates = @(
        'D4DE20D05E66FC53FE1A50882C78DB2852CAE474'   # All customers, Baltimore CyberTrust Root
        , 'DF3C24F9BFD666761B268073FE06D1CC8D4F82A4' # Commercial, DigiCert Global Root G2
        , 'A8985D3A65E5E5C4B2D7D66D40C6DD2FB19C5436' # USGov, DigiCert Global Root CA
    )
    $ComputerName = hostname
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("\\$ComputerName\Root", [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $details = $store.Certificates | Where-Object { $expectedRootCertificates -contains $_.Thumbprint }
    $store.Close()
    $Global:isRootCertificatesOk = @($details).Count -gt 1
    $details              = $details | Select-Object -Property Thumbprint, Subject, Issuer, NotBefore, NotAfter
    if ($Global:isRootCertificatesOk)
    {
        "Root Certificates are installed on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
    } else 
    {
        "Root Certificates are NOT installed on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
        $details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
    }
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
}

function Get-mdiSensorVersion
{   
    try 
    {
        $ComputerName = hostname 
        $serviceParams = @{
            ComputerName = $ComputerName
            Namespace    = 'root\cimv2'
            Class        = 'Win32_Service'
            Property     = 'Name', 'PathName', 'State'
            Filter       = "Name = 'AATPSensor'"
            ErrorAction  = 'SilentlyContinue'
        }
        $service = Get-WmiObject @serviceParams
        if ($service) 
        {
            $versionParams = @{
                ComputerName = $ComputerName
                Namespace    = 'root\cimv2'
                Class        = 'CIM_DataFile'
                Property     = 'Version'
                Filter       = 'Name={0}' -f ($service.PathName -replace '\\', '\\')
                ErrorAction  = 'SilentlyContinue'
            }
            "Found the following Sensor Version installed on this DC: {0}" -f (Get-WmiObject @versionParams).Version | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
            $Global:SensorVersion = (Get-WmiObject @versionParams).Version
            $Global:Sensor_Version_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"
        }
        else
        {
            "No Sensor was found to be installed on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
            $Global:SensorVersion = "No Sensor was found to be installed on this DC"
            $Global:Sensor_Version_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"
        }
    } catch 
    {
        "No Sensor was found to be installed on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
        $Global:SensorVersion = "No Sensor was found to be installed on this DC"
        $Global:Sensor_Version_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"
    }
}
 
function Get-mdiCaptureComponent 
{
    $ComputerName = hostname
    $uninstallRegKey = 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
    try 
    {
        $Found = $False
        foreach ($registryView in @("Registry32", "Registry64")) 
        {
            
            $hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey("LocalMachine", $registryView)
            $uninstallRef = $hklm.OpenSubKey($uninstallRegKey)
            $applications = $uninstallRef.GetSubKeyNames()
            
            foreach ($app in $applications) 
            {
                $appDetails = $hklm.OpenSubKey($uninstallRegKey + '\' + $app)            
                if ($appDetails.GetValue('DisplayName') -match 'npcap|winpcap') 
                {
                    $Global:appDisplayName = $appDetails.GetValue('DisplayName')
                    $Global:appVersion = $appDetails.GetValue('DisplayVersion')
                    "Found the following Capturing Component on this DC: {0} ({1})" -f $Global:appDisplayName, $Global:appVersion | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
                    if($Found -eq $True){
                        $Global:Capturing_Comp = $Global:Capturing_Comp + " \\ " + $Global:appDisplayName + " " + $Global:appVersion
                    }
                    else{
                    
                    $Global:Capturing_Comp = $Global:appDisplayName + " " + $Global:appVersion

                    }
                    $Global:Capture_Comp_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"
                    $Found = $True
                }
            }
            $hklm.Close()
        }
    } catch 
    {
        "No Capturing Component was found on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
        $Global:Capturing_Comp = "No Capturing Component was found on this DC"
        $Global:Capture_Comp_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"

    }
    Finally{
        if ($Found -eq $False){
            "No Capturing Component was found on this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
            $Global:Capturing_Comp = "No Capturing Component was found on this DC"
            $Global:Capture_Comp_URL = "<a href='VM_Checks.txt'>VM Checks Details</a>"
            
        
        }

    
    }
}
  
function Get-mdiMachineType 
{
    $ComputerName = hostname
    $csiParams = @{
        ComputerName = $ComputerName
        Namespace    = 'root\cimv2'
        Class        = 'Win32_ComputerSystem'
        Property     = 'Model', 'Manufacturer'
        ErrorAction  = 'SilentlyContinue'
    }
    $csi = Get-WmiObject @csiParams
    $Global:MachineType = switch ($csi.Model) {
        { $_ -eq 'Virtual Machine' } { 'Hyper-V'; break }
        { $_ -match 'VMware|VirtualBox' } { $_; break }
        default {
            switch ($csi.Manufacturer) {
                { $_ -match 'Xen|Google' } { $_; break }
                { $_ -match 'QEMU' } { 'KVM'; break }
                { $_ -eq 'Microsoft Corporation' } {
                    $azgaParams = @{
                        ComputerName = $ComputerName
                        Namespace    = 'root\cimv2'
                        Class        = 'Win32_Service'
                        Filter       = "Name = 'WindowsAzureGuestAgent'"
                        ErrorAction  = 'SilentlyContinue'
                    }
                    if (Get-WmiObject @azgaParams) { 'Azure' } else { 'Hyper-V' }
                    break
                }
                default {
                    $cspParams = @{
                        ComputerName = $ComputerName
                        Namespace    = 'root\cimv2'
                        Class        = 'Win32_ComputerSystemProduct'
                        Property     = 'uuid'
                        ErrorAction  = 'SilentlyContinue'
                    }
                    $uuid = (Get-WmiObject @cspParams).UUID
                    if ($uuid -match '^EC2') { 'AWS' } else { 'Platform' }
                }
            }
        }
    }
    "Machine Type is: {0}" -f $Global:MachineType | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt" -append
}

function Get-mdiAdfsAuditing
{   
    $Domain = $env:USERDNSDOMAIN
    $expectedAuditing = @'
SecurityIdentifier,AccessMask,AuditFlagsValue,AceFlagsValue
S-1-1-0,48,3,194
'@ | ConvertFrom-Csv

    $ds = [adsi]('LDAP://{0}/ROOTDSE' -f $Domain)
    $ldapPath = 'LDAP://CN=ADFS,CN=Microsoft,CN=Program Data,{0}' -f $ds.defaultNamingContext.Value
    $result = Get-mdiDsSacl -LdapPath $ldapPath -ExpectedAuditing $expectedAuditing
    $Global:AdfsAuditing = $result.isAuditingOk
    if ($result.isAuditingOk)
    {
        "ADFS auditing is configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    else
    {
        "ADFS auditing is NOT configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
}

function Get-mdiObjectAuditing
{   
    $Domain = $env:USERDNSDOMAIN
    $expectedAuditing = @'
SecurityIdentifier,AccessMask,AuditFlagsValue,InheritedObjectAceType,Description
S-1-1-0,852331,1,bf967aba-0de6-11d0-a285-00aa003049e2,Descendant User Objects
S-1-1-0,852331,1,bf967a9c-0de6-11d0-a285-00aa003049e2,Descendant Group Objects
S-1-1-0,852331,1,bf967a86-0de6-11d0-a285-00aa003049e2,Descendant Computer Objects
S-1-1-0,852331,1,ce206244-5827-4a86-ba1c-1c0c386c1b64,Descendant msDS-ManagedServiceAccount Objects
S-1-1-0,852331,1,7b8b558a-93a5-4af7-adca-c017e67f1057,Descendant msDS-GroupManagedServiceAccount Objects
'@ | ConvertFrom-Csv | Select-Object SecurityIdentifier, AccessMask, AuditFlagsValue, InheritedObjectAceType

    $ds = [adsi]('LDAP://{0}/ROOTDSE' -f $Domain)
    $ldapPath = 'LDAP://{0}' -f $ds.defaultNamingContext.Value
    $result = Get-mdiDsSacl -LdapPath $ldapPath -ExpectedAuditing $expectedAuditing
    $Global:ObjectAuditing = $result.isAuditingOk
    
    if ($result.isAuditingOk)
    {
        "MDI related DS Object Auditing is configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    else 
    {
        "MDI related DS Object Auditing is NOT configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
}

function Get-mdiExchangeAuditing
{    
    $Domain = $env:USERDNSDOMAIN
    $expectedAuditing = @'
SecurityIdentifier,AccessMask,AuditFlagsValue,AceFlagsValue
S-1-1-0,32,3,194
'@ | ConvertFrom-Csv

    $ds = [adsi]('LDAP://{0}/ROOTDSE' -f $Domain)
    $ldapPath = 'LDAP://CN=Configuration,{0}' -f $ds.defaultNamingContext.Value
    $result = Get-mdiDsSacl -LdapPath $ldapPath -ExpectedAuditing $expectedAuditing
    $Global:ExchangeAuditing = $result.isAuditingOk
    if($result.isAuditingOk)
    {
        "MDI related Exchange auditing is configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    else
    {
        "MDI related Exchange auditing is NOT configured" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
        $result.details | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
    }
    "##############################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Auditing_Checks.txt" -append
}

function Get-mdiDsSacl
{
    param (
        [Parameter(Mandatory = $true)] [string] $LdapPath,
        [Parameter(Mandatory = $true)] [object[]] $ExpectedAuditing
    )

    $searcher = [System.DirectoryServices.DirectorySearcher]::new(([adsi]$LdapPath))
    $searcher.CacheResults = $False
    $searcher.SearchScope = [System.DirectoryServices.SearchScope]::Base
    $searcher.ReferralChasing = [System.DirectoryServices.ReferralChasingOption]::All
    $searcher.SecurityMasks = [System.DirectoryServices.SecurityMasks]::Sacl
    $searcher.PropertiesToLoad.AddRange(('ntsecuritydescriptor,distinguishedname,objectsid' -split ','))
    try 
    {
        $result = ($searcher.FindOne()).Properties
        $appliedAuditing = [Security.AccessControl.RawSecurityDescriptor]::new($result['ntsecuritydescriptor'][0], 0) |
            ForEach-Object { $_.SystemAcl } | Select-Object *,
            @{N = 'AcessMaskDetails'; E = { ([Enum]::ToObject([System.DirectoryServices.ActiveDirectoryRights], $_.AccessMask)) } },
            @{N = 'AuditFlagsValue'; E = { $_.AuditFlags.value__ } },
            @{N = 'AceFlagsValue'; E = { $_.AceFlags.value__ } }
        $properties = ($expectedAuditing | Get-Member -MemberType NoteProperty).Name
        $compareParams = @{
            ReferenceObject  = $expectedAuditing | Select-Object -Property $properties
            DifferenceObject = $appliedAuditing | Select-Object -Property $properties
            Property         = $properties
        }
        $return = [pscustomobject]@{
            isAuditingOk = @(Compare-Object @compareParams -ExcludeDifferent -IncludeEqual).Count -eq $expectedAuditing.Count
            details      = $appliedAuditing
        }
    } catch 
    {
        $e = $_
        $return = [pscustomobject]@{
            isAuditingOk = $False
            details      = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
        }
    }
    $return
}

function Get-Other 
{
    Get-service AATPSensorUpdater -RequiredServices	>> "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt"
    netsh http show servicestate >>  "$($Export_Folder_Path)\MDI_Export_Folder\VM_Checks.txt"
    MSINFO32.exe /nfo "$($Export_Folder_Path)\MDI_Export_Folder\MSINFO\MSINFO32.NFO" /categories +all
	netsh wfp show state file="$($Export_Folder_Path)\MDI_Export_Folder\WFP\wfp_state.xml" | out-null
	netsh wfp show netevents file="$($Export_Folder_Path)\MDI_Export_Folder\WFP\wfp_netevents.xml" | out-null
	netsh wfp show filters file="$($Export_Folder_Path)\MDI_Export_Folder\WFP\wfp_filters.xml" | out-null
    tasklist /svc >> "$($Export_Folder_Path)\MDI_Export_Folder\Tasks.txt"
	Tasklist.exe /M >> "$($Export_Folder_Path)\MDI_Export_Folder\Tasks.txt"
}

function Get-SSLandCrypto
{
    "SSL and Crypto Keys Export from this DC" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
    "" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" -append
	reg query HKLM\SYSTEM\CurrentControlSet\Control\Cryptography /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" 
	reg query HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" 
	reg query HKLM\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" 
	reg query HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002 /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt" 
    reg query HKLM\System\currentcontrolset\control\Cryptography\Configuration\local\SSL\00010002 /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Certs_SSL_Checks.txt"
}

function Get-NetworkSettings
{
    "Network Settings" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    "" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    ipconfig /all >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
	"##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    netstat -ano >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
	"##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    route print >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
    "##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
	netsh int ipv4 show dynamicport tcp >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
    "##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
	netsh int ipv4 show dynamicport udp >>"$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
    "##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    type c:\windows\system32\drivers\etc\hosts >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
	"##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
    reg query HKLM\SYSTEM\CurrentControlSet\Services\Tcpip /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
    "##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
	reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
    "##############################################################################################################################################################################################################################" | Out-File -FilePath "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt" -append
	reg query "HKEY_USERS\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /s >> "$($Export_Folder_Path)\MDI_Export_Folder\Network_Settings.txt"
}

function Set-MdiReadinessReport 
{ 
   
$header = @"
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
    <head>
    <title>MDI Support Script</title>
    <style type="text/css">
    <!--
        body 
        {
            background-color: #E0E0E0;
            font-family: sans-serif
        }
        table, th, td 
        {
            background-color: white;
            border-collapse:collapse;
            border: 1px solid #E0E0E0;
            padding: 5px
        }
    -->
    </style>
"@



$body = @"
    <h1>$(hostname) MDI Collected Information</h1>
    <h2>Domain is $($env:USERDNSDOMAIN)</h2>
    <p>The following data was collected on $(get-date).</p>
"@


$results =  @([PSCustomObject]@{MDI_Requirement = "Adfs Auditing";Pass = $AdfsAuditing;Collected_Details = "<a href='Auditing_Checks.txt'>Auditing Details</a>";Guide = "<a href='https://aka.ms/mdi/adfsauditing'>ADFS Auditing</a>"},
[PSCustomObject]@{MDI_Requirement = "Object Auditing";Pass = $ObjectAuditing;Collected_Details = "<a href='Auditing_Checks.txt'>Auditing Details</a>";Guide = "<a href='https://aka.ms/mdi/ObjectAuditing'>Object Auditing</a>"},
[PSCustomObject]@{MDI_Requirement = "Exchange Auditing";Pass = $ExchangeAuditing;Collected_Details = "<a href='Auditing_Checks.txt'>Auditing Details</a>";Guide = "<a href='https://aka.ms/mdi/ExchangeAuditing'>Exchange Auditing</a>"},
[PSCustomObject]@{MDI_Requirement = "Advanced Auditing";Pass = $Global:isAdvancedAuditingOk;Collected_Details = "<a href='Auditing_Checks.txt'>Auditing Details</a>";Guide = "<a href='https://aka.ms/mdi/advancedauditing'>Advanced Auditing</a>"},
[PSCustomObject]@{MDI_Requirement = "NTLM Auditing";Pass = $Global:isNtlmAuditingOk;Collected_Details = "<a href='Auditing_Checks.txt'>Auditing Details</a>";Guide = "<a href='https://aka.ms/mdi/ntlmauditing'>NTLM Auditing</a>"},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "Root Certificates Readiness";Pass = $Global:isRootCertificatesOk;Collected_Details = "<a href='Certs_SSL_Checks.txt'>Certs and SSL Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/troubleshooting-known-issues#proxy-authentication-problem-presents-as-a-connection-error'>MDI Root Certificates</a>"},
[PSCustomObject]@{MDI_Requirement = "SSL and Crypto Registry";Pass = "Collected";Collected_Details = "<a href='Certs_SSL_Checks.txt'>Certs and SSL Details</a>";Guide = ""},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "Sensor Logs";Pass = $Global:SensorLogsCollected;Collected_Details = $Global:SensorLogsURL;Guide = ""},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "GPO Results";Pass = "Collected";Collected_Details = "<a href='gpresult.htm'>GPO Results</a>";Guide = ""},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "Portal Connection Test";Pass = $Global:isPortalConnOk ;Collected_Details = "<a href='Proxy_Connections_Checks.txt'>Proxy and Connections Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/prerequisites#defender-for-identity-firewall-requirements'>MDI Network Requirements</a>"},
[PSCustomObject]@{MDI_Requirement = "Sensor API Connection Test";Pass = $Global:isSensorAPIConnOk;Collected_Details = "<a href='Proxy_Connections_Checks.txt'>Proxy and Connections Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/prerequisites#defender-for-identity-firewall-requirements'>MDI Network Requirements</a>"},
[PSCustomObject]@{MDI_Requirement = "Network Settings";Pass = "Collected";Collected_Details = "<a href='Network_Settings.txt'>Network Settings</a>";Guide = ""},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "DSA Access to Deleted Objects";Pass = $Global:DeletedObjPermission ;Collected_Details = "<a href='DSA_Checks.txt'>DSA Tests Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/directory-service-accounts#permissions-required-for-the-dsa'>DSA Permissions Requirements</a>"},
[PSCustomObject]@{MDI_Requirement = "DSA is a normal user";Pass = $Global:isNormalUser ;Collected_Details = "<a href='DSA_Checks.txt'>DSA Tests Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/directory-service-accounts#types-of-dsa-accounts'>DSA Types</a>"},
[PSCustomObject]@{MDI_Requirement = "DSA is a gMSA";Pass = $Global:isGMSA ;Collected_Details = "<a href='DSA_Checks.txt'>DSA Tests Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/directory-service-accounts#types-of-dsa-accounts'>DSA Types</a>"},
[PSCustomObject]@{MDI_Requirement = "gMSA Password Can be Retrieved";Pass = $Global:GmsaPWRet ;Collected_Details = "<a href='DSA_Checks.txt'>DSA Tests Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/directory-service-accounts#types-of-dsa-accounts'>DSA Types</a>"},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "NNR RDP Test";Pass = $Global:NNR_RDP ;Collected_Details = "<a href='NNR_Checks.txt'>NNR Test Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/nnr-policy'>NNR Policy</a>"},
[PSCustomObject]@{MDI_Requirement = "NNR NTLM Test";Pass = $Global:NNR_NTLM ;Collected_Details = "<a href='NNR_Checks.txt'>NNR Test Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/nnr-policy'>NNR Policy</a>"},
[PSCustomObject]@{MDI_Requirement = "NNR NetBIOS Test";Pass = $Global:NNR_NetBIOS ;Collected_Details = "<a href='NNR_Checks.txt'>NNR Test Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/nnr-policy'>NNR Policy</a>"},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "OS Version";Pass = $Global:OS_Version ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = ""},
[PSCustomObject]@{MDI_Requirement = "Machine Type";Pass = $Global:MachineType ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = ""},
[PSCustomObject]@{MDI_Requirement = "Existing Sensor Version";Pass = $Global:SensorVersion ;Collected_Details = $Global:Sensor_Version_URL;Guide = ""},
[PSCustomObject]@{MDI_Requirement = "Sensor Process ID";Pass = $Global:Sensor_PID_Found ;Collected_Details = $Global:Sensor_Process_URL;Guide = ""},
[PSCustomObject]@{MDI_Requirement = "Capturing Component";Pass = $Global:Capturing_Comp ;Collected_Details = $Global:Capture_Comp_URL;Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/technical-faq#winpcap-and-npcap-drivers'>Capturing Drivers</a>"},
[PSCustomObject]@{MDI_Requirement = "DC is listening to RADIUS";Pass = $Global:isRadiusListen ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/vpn-integration'>VPN Integration</a>"},
[PSCustomObject]@{MDI_Requirement = "Power Scheme Test";Pass = $Global:isPowerSchemeOk ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = "<a href='https://learn.microsoft.com/en-us/defender-for-identity/prerequisites#server-specifications'>Server Specifications</a>"},
[PSCustomObject]@{MDI_Requirement = "Dependencies - Required Services";Pass = "Collected" ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = ""},
[PSCustomObject]@{MDI_Requirement = "Service State";Pass = "Collected" ;Collected_Details = "<a href='VM_Checks.txt'>VM Checks Details</a>";Guide = ""},
[PSCustomObject]@{},
[PSCustomObject]@{MDI_Requirement = "Tasks";Pass = "Collected";Collected_Details = "<a href='Tasks.txt'>Tasks Details</a>";Guide = ""},
[PSCustomObject]@{MDI_Requirement = "MS Info";Pass = "Collected";Collected_Details = "<a href='MSINFO'>MS Info</a>";Guide = ""},
[PSCustomObject]@{MDI_Requirement = "WFP Details";Pass = "Collected";Collected_Details = "<a href='WFP'>WFP Details</a>";Guide = ""}
)
 
                  

$results2 = $results | ConvertTo-Html -head $header -body $body | foreach {
    $PSItem -replace "<td>True</td>", "<td style='background-color:#4aa564'>True</td>" -replace "<td>False</td>", "<td style='background-color:#cd2026'>False</td>" -replace "<td></td>", "<td style='background-color:#E0E0E0'></td>"
    } 
    Add-Type -AssemblyName System.Web
    [System.Web.HttpUtility]::HtmlDecode($results2) | Out-File "$($Export_Folder_Path)\MDI_Export_Folder\MDI_Summary.html"
}

#Functions Invokation

Get-mdiAdfsAuditing
Get-mdiObjectAuditing
Get-mdiExchangeAuditing
Get-mdiAdvancedAuditing
Get-mdiNtlmAuditing

Get-mdiCertReadiness
Get-SSLandCrypto

Export-Logs

Get-GPO

Get-ConnectionsStatus
Get-NetworkSettings

Get-MDIUserPermissions
Get-DeletedObjectsPermissions

Get-NNRStatus

Get-RadiusStatus
Get-mdiPowerScheme
Get-mdiSensorVersion
Get-mdiCaptureComponent
Get-mdiMachineType

Get-Other
Set-MdiReadinessReport