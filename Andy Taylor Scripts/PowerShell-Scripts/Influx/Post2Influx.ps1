$influxserver="http://172.16.21.3:8086"
$influxuser="powershell"
$influxpass="powershell"
$db="Powershell"


function post-influx {
Param(
  [string]$data
  )

$authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes($influxuser+":"+$influxpass)))
$uri = $influxserver+"/write?db="+$db
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $uri -Method POST -Body $data
}

$Volumes=Get-Volume | where {$_.driveletter}

foreach($volume in $volumes)
{
$drive=$volume.DriveLetter
$size=$volume.Size
$space=$volume.SizeRemaining
if ($volume.HealthStatus -eq "Healthy"){$Health="T"}
else {$Health="F"}

$postdata = "Disk,Host="+$env:COMPUTERNAME+",DRIVE="+$drive+" SIZE="+$size+",SPACE="+$space+",Health="+$health
post-influx -data $postdata
}
