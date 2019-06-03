while($true)
{
Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average
Get-Counter '\Memory\Available MBytes'
Get-Counter '\Processor(_Total)\% Processor Time'
Start-Sleep 1
}