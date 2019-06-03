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




while($true)
{

$vms=get-vm
get-vm
foreach($vm in $vms){
$name=$vm.name
$state=$vm.State
$MemoryA=$vm.MemoryAssigned
$MemoryD=$vm.MemoryDemand


$postdata = "HyperV,Host="+$env:COMPUTERNAME+",NAME="+$name+" RAM_ASSIGNED="+$MemoryA+",RAM_DEMAND="+$MemoryD+",STATE="""+$state+""" 1"
write-host $postdata
post-influx -data $postdata
}
Start-Sleep 300


}
