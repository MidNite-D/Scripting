# Recursivly set permissions - Andy T
#  make sure there is a \ at the end of the base path and set the execution policy before running.

$basepath = "D:\Users\pupils\"
$dirs = Get-ChildItem $basepath

foreach ($dir in $dirs){

$path = $basepath + $dir
Get-Acl $path | Format-List
$acl = Get-Acl $path
#set first bit to $true to disable inherit
$acl.SetAccessRuleProtection($False, $True)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($dir,"FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $path $acl
Get-Acl $path  | Format-List
}