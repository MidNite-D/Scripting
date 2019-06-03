


$servers="DC-01","DC-02" 

while($true)
{
foreach($server in $servers)
{
     if(Test-Connection -ComputerName $server -Quiet -Count 1) {   
         New-Object -TypeName PSCustomObject -Property @{
             VMName = $server
             'Ping Status' = 'Ok'
             'Time' = Get-Date      
         }  | Export-Csv -Path VMPingStatus.csv -NoTypeInformation -Append
     } else {
         New-Object -TypeName PSCustomObject -Property @{
             VMName = $server
             'Ping Status' = 'Failed' 
             'Time' = Get-Date 
            } | Export-Csv -Path VMPingStatus.csv -NoTypeInformation -Append
         }
}
start-sleep 30
}




