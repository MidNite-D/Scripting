$basepath="\"    #####  Keep the \
$ResourceOU=""   ##### OU of Domain Local Groups
$UserOU=""       ##### OU of Global Groups

$dirs=Get-ChildItem $basepath
foreach($dir in $dirs)
{

#  Create Groups
$Readname=$dir.Name+"_Read"
$Writename=$dir.name+"_Write"
$UserReadname=$Readname+"_Users"
$UserWritename=$Writename+"_Users"
new-adgroup -GroupScope DomainLocal -GroupCategory Security -name $Readname -Path $ResourceOU
new-adgroup -GroupScope DomainLocal -GroupCategory Security -name $Writename -Path $ResourceOU
new-adgroup -GroupScope Global -GroupCategory Security -name $UserReadname -Path $UserOU
new-adgroup -GroupScope Global -GroupCategory Security -name $UserWritename -Path $UserOU


# Add Domain Local to Global
Add-ADGroupMember -Identity $Readname -Members $UserReadname
Add-ADGroupMember -Identity $Writename -Members $UserWritename

# Set directory Permissions
$path = $basepath + $dir
$dir.BaseName
$acl = (Get-Item $path).GetAccessControl('Access')
$acl.SetAccessRuleProtection($False, $True)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Writename,"modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $path $acl
$acl.SetAccessRuleProtection($False, $True)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Readname,"readandexecute", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $path $acl
}
