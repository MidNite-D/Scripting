$Computers=Get-ADComputer -searchbase "OU=Curriculum,OU=Computers,OU=Ninelands Primary,DC=nps,DC=lan" -Filter *

foreach($computer in $computers)
{
Stop-Computer $computer.dnsHostName
}

