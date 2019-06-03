Function Get-Telnet
{   Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @("username","password","disable clipaging","sh config"),
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "23",
        [int]$WaitTime = 100,
        [string]$OutputPath = "log.txt"
    )
    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.AsciiEncoding

        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   $Writer.WriteLine($Command) 
            $Writer.Flush()
            $Command
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
            write-host $Result
        }
    }
    Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    #Done, now save the results to a file
    #$Result | Out-File $OutputPath
}

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



$WAPS=import-csv .\waps.csv

foreach($WAP in $WAPS){


$ip=$WAP.ip
$hostname=$WAP.hostname
$domainname=$WAP.domainname
$ssid=$WAP.ssid
$channel=$WAP.channel
$key=$WAP.key




$connected=$FALSE
Write-Host "Connecting...."
do{
$connected=Test-Port $ip 23
}
until($connected -eq $TRUE)
Write-Host "Connected."

Start-Sleep 4

Copy-Item .\AESTEMPLATE.txt .\AESCONFIG
(Get-Content .\AESCONFiG) | ForEach-Object { $_ -replace "_HOSTNAME",$hostname } | Set-Content .\AESCONFiG
(Get-Content .\AESCONFiG) | ForEach-Object { $_ -replace "_DOMAINNAME",$domainname } | Set-Content .\AESCONFiG
(Get-Content .\AESCONFiG) | ForEach-Object { $_ -replace "_SSID",$ssid } | Set-Content .\AESCONFiG
(Get-Content .\AESCONFiG) | ForEach-Object { $_ -replace "_CHANNEL",$channel } | Set-Content .\AESCONFiG
(Get-Content .\AESCONFiG) | ForEach-Object { $_ -replace "_KEY",$key } | Set-Content .\AESCONFiG

$content=get-content .\AESCONFiG
Get-Telnet -RemoteHost $ip -Commands $content -OutputPath ".\test.txt"
start-sleep 5
$connected=$FALSE
Write-Host "Connecting...."
do{
$connected=Test-Port $ip 23
}
until($connected -eq $TRUE)
Write-Host "Connected."
$content=get-content .\COMPLETE
Get-Telnet -RemoteHost $ip -Commands $content -OutputPath ".\test.txt"
Remove-Item .\AESCONFIG
}


