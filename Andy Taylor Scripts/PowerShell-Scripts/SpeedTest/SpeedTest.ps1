$CSV="c:\speed.csv"
$INTERVAL=600


Remove-Item $CSV
$header="Date,Time,Speed" |Add-Content $CSV

while ($true)
{

$date=get-date -Format d
$time=Get-Date -UFormat %R
$Request=Get-Date; Invoke-WebRequest 'http://client.akamai.com/install/test-objects/10MB.bin' | Out-Null;
[int]$speed = ((10 / ((NEW-TIMESPAN –Start $Request –End (Get-Date)).totalseconds)) * 8)
"{0:N2}" -f $Speed

Write-host $date "$($speed) Mbit/sec"
Add-Content $CSV $date","$time","$speed
start-sleep -s $INTERVAL
}