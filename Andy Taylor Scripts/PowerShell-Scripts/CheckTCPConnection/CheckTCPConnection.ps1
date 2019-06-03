function Test-Port($hostname, $port)
{
    # This works no matter in which form we get $host - hostname or ip address
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
            select-object IPAddressToString -expandproperty  IPAddressToString
        if($ip.GetType().Name -eq "Object[]")
        {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]
        }
    } catch {
        Write-Host "Possibly $hostname is wrong hostname or IP"
        return
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try
    {
        $t.Connect($ip,$port)
    } catch {}

    if($t.Connected)
    {
        $t.Close()
        $msg = "Port $port is operational"
        Write-Host "Connected."
        return $TRUE
    }
    else
    {
       Write-Host "Connecting...."                                 
        return $FALSE
    }
}



$connected=$FALSE
Write-Host "Connecting...."
do{
$connected=Test-Port 192.168.1.11 23
}
until($connected -eq $TRUE)
Write-Host "Finished."
