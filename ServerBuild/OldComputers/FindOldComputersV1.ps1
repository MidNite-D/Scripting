#### Fill This bit in ############################################

$logondate = (Get-Date).AddDays(-90) # The 60 is the number of days from today since the last logon.
$action="find" # Set action to "find" "disable" or "delete"

##################################################################
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $logondate} | FT Name,lastLogonDate
$m=Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $logondate} | measure
write-host "Accounts Found : " $m.Count

if ($action -eq "disable") 
{
Write-host "Setting accounts to disabled."
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $logondate} | Set-ADComputer -Enabled $false
}

if ($action -eq "delete")
{
Write-host "Deleting Accounts"
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $logondate} | Remove-ADComputer
}