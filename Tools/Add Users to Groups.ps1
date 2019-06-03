# Add users to AD groups

$Groups = Import-Csv -Delimiter "," -Path "c:\Westwood\Westwoodpupils.csv"
foreach ($ac in $groups){
Add-ADGroupMember -Identity $ac.Year -Members $ac.username
}

