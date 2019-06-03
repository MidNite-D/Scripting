$Hosts=Import-Csv -path "C:\Users\connect\Desktop\Book1.csv"
foreach($hostn in $hosts){
$hostname=$hostn.Hostname
$hostname
shutdown /m \\$hostname /r /t 0
}