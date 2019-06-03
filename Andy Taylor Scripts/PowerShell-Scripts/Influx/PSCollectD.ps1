$influxserver="http://172.16.21.3:8086"
$influxuser="powershell"
$influxpass="powershell"
$db="Powershell"
$CPUCheckInterval=10
$DiskCheckInterval=20






$LaunchTime=Get-Date

$CPULastTick=$LaunchTime
$DiskLastTick=$LaunchTime
$HyperVLastTick=$LaunchTime

$ServicePoint = [System.Net.ServicePointManager]::FindServicePoint("$influxserver/write?db=$db")


$Freespace = @{
  Expression = {[int]($_.Freespace/1GB)}
  Name = 'Free Space (GB)'
}

$SizeGB = @{
  Expression = {[int]($_.Size/1GB)}
  Name = 'Disk Size (GB)'
}

$PercentFree = @{
  Expression = {[int]($_.Freespace*100/$_.Size)}
  Name = 'Free (%)'
}


function post-influx {
Param(
  [string]$data
  )

$authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes($influxuser+":"+$influxpass)))
$uri = $influxserver+"/write?db="+$db
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $uri -Method POST -Body $data
$ServicePoint.CloseConnectionGroup("")
}


while($true)
{
$now=Get-Date


$CPUTrigger=$CPULastTick.AddSeconds($CPUCheckInterval)
$DiskTrigger=$DISKLastTick.AddSeconds($DiskCheckInterval)
$HyperVTrigger=$HyperVLastTick.AddSeconds($HyperVCheckInterval)



###### CPU READING

if($now -gt $CPUTrigger){
$CPULastTick=$now
write-host "CPUTick - $now"
$proc=get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2

$cpu=($proc.readings.Substring($proc.readings.Length-19,6))
if($cpu -eq "ocesso"){$cpu=0} 
$cpu
$postdata = "CPU,Host="+$env:COMPUTERNAME+" CPUUsage="+$cpu
$postdata
post-influx -data $postdata

}



####### DISK READING

if($now -gt $DiskTrigger){
$DiskLastTick=$now
write-host "DiskTick - $now"
$Volumes=Get-WmiObject -Class Win32_LogicalDisk | where{$_.VolumeName}|
  Select-Object -Property DeviceID, VolumeName, $Freespace, $PercentFree, $SizeGB

foreach($volume in $volumes)
{
$drive=$volume.DeviceID
$size=$volume.'Disk Size (GB)'
$space=$volume.'Free Space (GB)'
$spacepercent=$volume.'Free (%)'



if ($volume.HealthStatus -eq "Healthy"){$Health="T"}
else {$Health="F"}

$postdata = "Disk,Host="+$env:COMPUTERNAME+",DRIVE="+$drive+" SIZE="+$size+",SPACE="+$space+",Health="+$health+",PERCENT="+$spacepercent
$postdata
post-influx -data $postdata
}

}


Start-Sleep 1


}