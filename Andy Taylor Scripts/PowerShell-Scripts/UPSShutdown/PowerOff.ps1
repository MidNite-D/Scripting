#### Shutdown Script ####


# Shutdown all computers in the member servers OU #
$Computers=Get-ADComputer -searchbase "OU=MemberServers,OU=Computers,OU=ConnectUp,DC=cuss,DC=local" -Filter *
foreach($computer in $computers){
    Stop-Computer $computer.dnsHostName
    }
sleep 60

# Shutdown Specific Servers.
# List servers here (do not include local server)"
$Computers="Gateway02.cuss.local","HyperV-04.Cuss.local","HyperV-03.cuss.local","HyperV-02.cuss.local"

foreach($computer in $computers){
    Stop-Computer $computer
    }

Stop-Computer 
