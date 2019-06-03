
$msg=$args[0]
$computers = Get-ADComputer -Filter *
Write-Host "Retrieved "$computers.Count" computers from Active Directory."
Write-Host "Testing for SIMS directory..."
foreach($computer in $computers){
$hostname=$computer.name
if((Test-Path "\\$hostname\c$\program files (x86)\SIMS") -or (Test-Path "\\$hostname\c$\program files\SIMS")){
Write-Host "** SIMS Directory Found**"
Write-Host "Sending notification to "$hostname
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * /time:600 $msg" -ComputerName $computer.name |Out-Null
}
}