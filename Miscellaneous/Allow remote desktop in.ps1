# Small script to allow (not enable) RDP in and file shareing rules in firewall
$Action = 'Allow'
$RDPTCP = Get-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-IN)"
$RDPUDP = Get-NetFirewallRule -DisplayName "Remote Desktop - User Mode (UDP-IN)"
$FilePrinterSharingIPv4 = get-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
$FilePrinterSharingIPv6 = get-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv6-In)"
$WINrm = Get-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

if ($RDPTCP.Action -ne 'Allow') {
    set-NetFirewallRule -DisplayName $RDPTCP -Action $Action
}
if ($RDPUDP.Action -ne 'Allow') {
    set-NetFirewallRule -DisplayName $RDPUDP -Action $Action
}
if ($FilePrinterSharingIPv4.Action -ne 'Allow') {
    set-NetFirewallRule -DisplayName $FilePrinterSharingIPv4 -Action $Action
}
if ($FilePrinterSharingIPv6.Action -ne 'Allow') {
    set-NetFirewallRule -DisplayName $FilePrinterSharingIPv6 -Action $Action
}
if ($WINrm.Action -ne 'Allow') {
    set-NetFirewallRule -DisplayName $WINrm -Action $Action
}
