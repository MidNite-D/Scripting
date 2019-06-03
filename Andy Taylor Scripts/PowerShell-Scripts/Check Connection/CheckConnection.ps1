
while ($true){
Get-Content .\comps.txt | ForEach-Object {
$a=get-date

    if(Test-Connection -ComputerName $_ -Quiet -Count 1) {   
        New-Object -TypeName PSCustomObject -Property @{
            VMName = $_
            'Ping Status' = 'Ok'
            'Time' = $a
            'IP' = $_.IPV4Address
        }
    } else {
        New-Object -TypeName PSCustomObject -Property @{
            VMName = $_
            'Ping Status' = 'Failed'
            'Time' = $a 
        }    
    }
} | Export-Csv -Path VMPingStatus.csv -NoTypeInformation -Append
sleep 5
}

