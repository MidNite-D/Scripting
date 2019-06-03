### Bulk create email Alias ###

### Settings ###

$SchoolDomain="thorparch-leh.co.uk"
$NumberOfAlias=20

########################################


### connect to remote exchange (NB not same as office365)
$msolcred = get-credential
######connect-msolservice -credential $msolcred
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $msolcred -Authentication Basic -AllowRedirection
Import-PSSession $Session

for($i=1; $i -le $NumberOfAlias; $i++)
{
$address = ("ipad$i@$SchoolDomain")
write-host "Adding Alias: $address"
Set-Mailbox -Identity "ipad" -EmailAddresses @{Add=$address}
}

Get-Mailbox -Identity "ipad" |fl


