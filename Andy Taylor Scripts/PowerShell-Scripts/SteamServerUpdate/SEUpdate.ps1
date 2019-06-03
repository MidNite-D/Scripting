$ExecPath=split-path -parent $MyInvocation.MyCommand.Definition



##FUNCTIONS


#Check Steam and Local Versions
function Check-Version($AppId, $Manifest)
{

Remove-Item $ExecPath\SteamInfo.txt
C:\servers\SteamCMD\steamcmd.exe +login anonymous +app_info_print $AppId +app_info_print $Appid +exit > $ExecPath\SteamInfo.txt

$SteamBuildID=Select-String -Path $ExecPath\SteamInfo.txt -pattern buildid
$SteamBuildID=$SteamBuildID[0].line.substring($SteamBuildID[0].line.length - 8, 8)

$LocalBuildID=Select-String -Path $Manifest -pattern buildid
$LocalBuildID=$LocalBuildID.line.substring($LocalBuildID.line.length - 8, 8)
if($SteamBuildID -eq $LocalBuildID){Return $False,$SteamBuildID,$LocalBuildID}
else{
Return $True,$SteamBuildID,$LocalBuildID}
}


#Check Server Is responding.
function Check-Process($process){

$ProcessActive = Get-Process $Process -ErrorAction SilentlyContinue
if($ProcessActive -eq $null){return $False}
else{return $True}
}


#Check UDP port is answering
function Check-Port($hostname, $port, $UDPTimeout){

                    #Create object for connecting to port on computer  
                    $udpobject = new-Object system.Net.Sockets.Udpclient
                    #Set a timeout on receiving message 
                    $udpobject.client.ReceiveTimeout = $UDPTimeout 
                    #Connect to remote machine's port                
                    $udpobject.Connect("$hostname",$port) 
                    #Sends a message to the host to which you have connected. 
                    $a = new-object system.text.asciiencoding 
                    $byte = $a.GetBytes("$(Get-Date)") 
                    [void]$udpobject.Send($byte,$byte.length) 
                    #IPEndPoint object will allow us to read datagrams sent from any source.  
                    $remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0) 
                    Try { 
                        #Blocks until a message returns on this socket from a remote host. 
                        $receivebytes = $udpobject.Receive([ref]$remoteendpoint) 
                        [string]$returndata = $a.GetString($receivebytes)
                        If ($returndata) {
                           Write-Verbose "Connection Successful"  
                           return $TRUE
                        }                       
                    } Catch { 
                        If ($Error[0].ToString() -match "\bRespond after a period of time\b") { 
                            #Close connection  
                            $udpobject.Close()  
                            #Make sure that the host is online and not a false positive that it is open 
                            If (Test-Connection -comp $hostname -count 1 -quiet) { 
                                Write-Verbose "Connection Open"  
                                return $TRUE
                            } Else { 
                                <# 
                                It is possible that the host is not online or that the host is online,  
                                but ICMP is blocked by a firewall and this port is actually open. 
                                #> 
                                return $false                                
                            }                         
                        } ElseIf ($Error[0].ToString() -match "forcibly closed by the remote host" ) { 
                            #Close connection  
                            $udpobject.Close()  
                            Write-Verbose "Connection Timeout"    
                            return $false                     
                        } Else {                      
                            $udpobject.close() 
                        } 
                    }      

}



#Update Server
function Update-Server()
{
if(Check-Process "SpaceEngineersDedicated"){
    Write-Host "Stopping Server"
    stop-service se
    if(Check-Process "SpaceEngineersDedicated"){
    stop-process SpaceEngineersDedicated
    }
    }


write-Host "Updating Server"

C:\servers\SteamCMD\steamcmd.exe +login rooster790 !aswethink1 +force_install_dir "d:\Game Servers\SpaceEngineers\Master" +app_update 244850 validate +exit
}



#Start Up Server
function Start-Server()
{
Update-Server
Write-Host "Starting Server"
Start-Service se
}



######### SCRIPT ########
while($true){


#Check process is running, if not go and start it

if((Check-Process "SpaceEngineersDedicated") -eq $false){
write-Host "Process not running"
Start-Server
}


#Check port is open, if not, wait enough time for the boot process and test again, if still no joy, go and start it.
if((Check-Port "www.fourdegrees.co.uk" "27016" 10000) -eq $false){
    Write-Host "Port not responding"
    sleep 10000
    if((Check-Port "www.fourdegrees.co.uk" "27016" 10000) -eq $false){
    Write-Host "Port still not responding"
        Start-Server}
}

Write-Host "Server OK"

$UpdateNeeded=Check-Version "244850" "D:\Game Servers\SpaceEngineers\master\steamapps\appmanifest_244850.acf"

if($UpdateNeeded[0]){
Write-Host "Update Needed"
Update-Server}
else{
Write-Host "Server up to date. Local version: $($UpdateNeeded[2])   Steam Version: $($UpdateNeeded[1])"}
sleep 60
}



