Import-Module $PSScriptRoot\PSSQLite\PSSQLite.psd1

$influxserver="http://172.16.21.11:8086"
$influxuser="Eaton"
$influxpass="Eaton"
$db="Eaton"
$Database = "C:\Program Files (x86)\Eaton\IntelligentPowerProtector\db\mc2.db"
$ServicePoint = [System.Net.ServicePointManager]::FindServicePoint("http://172.16.21.11:8086/write?db=$db")



function post-influx {
Param(
  [string]$data
  )

$authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes($influxuser+":"+$influxpass)))
$uri = $influxserver+"/write?db="+$db
Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $uri -Method POST -Body $data
}


while($true){
#Invoke-SqliteQuery -DataSource $Database -Query "PRAGMA table_info(measures)"|format-table
$Result=Invoke-SqliteQuery -DataSource $Database -Query "SELECT date,value FROM measures WHERE ObjectID = 10  ORDER BY date DESC LIMIT 1"
$postdata = "PowerDraw,Host=Mind value="+$Result.value
$postdata
post-influx -data $postdata
$ServicePoint.CloseConnectionGroup("")

Start-Sleep 10


}