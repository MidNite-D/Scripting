

$influxserver="http://10.10.21.5:8086"
$influxuser="pshell"
$influxpass="pshell"
$db="PowershellStats"
$ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($influxserver + "/write?db=$db")



function post-influx {
Param(
  [string]$data
  )

$authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes($influxuser+":"+$influxpass)))
$uri = $influxserver+"/write?db="+$db
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $uri -Method POST -Body $data
}


while($true){

$info=cmd /c 'c:\gdrive\gdrive.exe about'
$result=($info[1] -replace "Used: ","") -replace " MB",""
$result=($info[1] -replace "Used: ","") -replace " GB",""
$result=($info[1] -replace "Used: ","") -replace " TB",""
$postdata = "Upload,Host=APP-01 value="+$Result
$postdata
post-influx -data $postdata
$ServicePoint.CloseConnectionGroup("")

Start-Sleep 300


}