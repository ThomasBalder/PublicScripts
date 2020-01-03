Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile' -name "EnableFirewall" -Value 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\PublicProfile' -name "EnableFirewall" -Value 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\Standardprofile' -name "EnableFirewall" -Value 0 
Restart-Service -Name mpssvc
