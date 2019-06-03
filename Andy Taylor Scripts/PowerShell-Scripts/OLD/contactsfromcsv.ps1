# To be ran on Exchnage
Import-Csv c:\x500\csccontacts.csv | ForEach { New-MailContact -Name $_.displayName -Firstname $_.givenName -Lastname $_.sn -ExternalEmailAddress $_.targetaddress -OrganizationalUnit "ibahealth.local/Offices/UKI/User Accounts/Contacts/CSC" }

Import-CSV c:\x500\cscaddx500.csv | foreach {

$Temp = Get-Mailcontact -identity $_.alias

$Temp.EmailAddresses +=“X500:” + $_.legacyexchangedn

set-mailcontact -instance $temp}
