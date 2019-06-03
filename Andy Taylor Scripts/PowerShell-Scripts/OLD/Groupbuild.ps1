### REQUIRES QAD CMDLETS###


$directory=read-host "Target Directory"
$group=read-host "Target Group"
$a=get-acl -path "$directory" | select -expand access
foreach ($i in $a)
{
$s=$i.identityreference
add-qadgroupmember "$group" "$s"
}
