

$nic=get-wmiobject win32_networkadapter | Where {$_.deviceid -eq 9}
if ($nic.macaddress -ne "00:22:64:76:F4:3B")
{
write-host "LAN Switching On"
$nic.enable()
}
else
{
write-host "LAN Switching Off"
$nic.disable()
}
