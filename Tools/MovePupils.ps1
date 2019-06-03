#Get path variables
$HomePath = Read-Host "Please enter the path to the pupils Home folders. This can be UNC or Local Drive."
$OUpath = Read-Host "Please enter the path to the Pupils OU container"


#Create new OU based on Year of pupils leaving

$date = Get-date
$year = $date.Year
New-ADOrganizationalUnit -Name "Leavers $year" -Path "$OUpath" -ProtectedFromAccidentalDeletion $False


#Move Year 6 users to new archive OU

Get-ADUser -Filter * -SearchBase "OU=Year 6,$OUpath"| Move-ADObject -TargetPath "OU=Leavers $year,$OUpath"


#Remove AD Group members from Year 6

$Yr6Group = Get-ADGroupMember "Year 6"
Remove-ADGroupMember -Identity "year 6" -Members $Yr6Group -Confirm:$false


#Move AD Group members from Year 5 to Year 6

$Yr5Group = Get-ADGroupMember "Year 5"
Remove-ADGroupMember -Identity "year 5" -Members $Yr5Group -Confirm:$false
Add-ADGroupMember "year 6" $Yr5Group

#Move AD Group members from Year 4 to Year 5

$Yr4Group = Get-ADGroupMember "Year 4"
Remove-ADGroupMember -Identity "year 4" -Members $Yr4Group -Confirm:$false
Add-ADGroupMember "year 5" $Yr4Group

#Move AD Group members from Year 3 to Year 4

$Yr3Group = Get-ADGroupMember "Year 3"
Remove-ADGroupMember -Identity "year 3" -Members $Yr3Group -Confirm:$false
Add-ADGroupMember "year 4" $Yr3Group

#Move AD Group members from Year 2 to Year 3

$Yr2Group = Get-ADGroupMember "Year 2"
Remove-ADGroupMember -Identity "year 2" -Members $Yr2Group -Confirm:$false
Add-ADGroupMember "year 3" $Yr2Group

#Move AD Group members from Year 1 to Year 2

$Yr1Group = Get-ADGroupMember "Year 1"
Remove-ADGroupMember -Identity "year 1" -Members $Yr1Group -Confirm:$false
Add-ADGroupMember "year 2" $Yr1Group



#Move Year 6 users to new archive OU

Get-ADUser -Filter * -SearchBase "OU=Year 6,$OUpath"| Move-ADObject -TargetPath "OU=Leavers $year,$OUpath"

#Move Year 5 users to new Year 6 OU

Get-ADUser -Filter * -SearchBase "OU=Year 5,$OUpath"| Move-ADObject -TargetPath "OU=Year 6,$OUpath"

#Move Year 4 users to new Year 5 OU

Get-ADUser -Filter * -SearchBase "OU=Year 4,$OUpath"| Move-ADObject -TargetPath "OU=Year 5,$OUpath"

#Move Year 3 users to new Year 4 OU

Get-ADUser -Filter * -SearchBase "OU=Year 3,$OUpath"| Move-ADObject -TargetPath "OU=Year 4,$OUpath"

#Move Year 2 users to new Year 3 OU

Get-ADUser -Filter * -SearchBase "OU=Year 2,$OUpath"| Move-ADObject -TargetPath "OU=Year 3,$OUpath"

#Move Year 1 users to new Year 2 OU

Get-ADUser -Filter * -SearchBase "OU=Year 1,$OUpath"| Move-ADObject -TargetPath "OU=Year 2,$OUpath"

#Move Year 6 Home folders to new Archive folder

New-Item -ItemType Directory "$HomePath\Leavers $year"
Move-Item -Path "$HomePath\Year 6\*" -destination "$HomePath\Leavers $year"

Move-Item -Path "$HomePath\Year 5\*" -destination "$HomePath\Year 6"

Move-Item -Path "$HomePath\Year 4\*" -destination "$HomePath\Year 5"

Move-Item -Path "$HomePath\Year 3\*" -destination "$HomePath\Year 4"

Move-Item -Path "$HomePath\Year 2\*" -destination "$HomePath\Year 3"

Move-Item -Path "$HomePath\Year 1\*" -destination "$HomePath\Year 2"




