$SchoolName="RichmondHouse"
$domain="RichmondHouse"
$tld="local"



Get-ADOrganizationalUnit -filter * | Set-ADObject -ProtectedFromAccidentalDeletion:$false

New-ADOrganizationalUnit -Name $SchoolName -Path "DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Computers -Path "OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Users -Path "OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Groups -Path "OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name ARCHIVE -Path "OU=$SchoolName,DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Staff -Path "OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Pupils -Path "OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Staff -Path "OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Pupils -Path "OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Resource -Path "OU=Groups,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name User -Path "OU=Groups,OU=$SchoolName,DC=$domain,DC=$tld"


New-ADOrganizationalUnit -Name Desktops -Path "OU=Staff,OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Mobile -Path "OU=Staff,OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Desktops -Path "OU=Pupils,OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Mobile -Path "OU=Pupils,OU=Computers,OU=$SchoolName,DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Foundation -Path "OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name KS1 -Path "OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name KS2 -Path "OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Year1 -Path "OU=KS1,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Year2 -Path "OU=KS1,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Year3 -Path "OU=KS2,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Year4 -Path "OU=KS2,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Year5 -Path "OU=KS2,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Year6 -Path "OU=KS2,OU=Pupils,OU=Users,OU=$SchoolName,DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Computers -Path "OU=ARCHIVE,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Users -Path "OU=ARCHIVE,OU=$SchoolName,DC=$domain,DC=$tld"

New-ADOrganizationalUnit -Name Pupils -Path "OU=Users,OU=ARCHIVE,OU=$SchoolName,DC=$domain,DC=$tld"
New-ADOrganizationalUnit -Name Staff -Path "OU=Users,OU=ARCHIVE,OU=$SchoolName,DC=$domain,DC=$tld"
