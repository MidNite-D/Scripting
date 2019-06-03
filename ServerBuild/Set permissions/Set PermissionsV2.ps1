# Recursivly set permissions - Andy T
#  make sure there is a \ at the end of the base path and set the execution policy before running.

$basepath = "D:\Users\Staff\"
$dirs = Get-ChildItem $basepath

foreach ($dir in $dirs){

$path = $basepath + $dir
$dir.BaseName
$acl = (Get-Item $path).GetAccessControl('Access')
#set first bit to $true to disable inherit
$acl.SetAccessRuleProtection($False, $True)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($dir,"modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $path $acl
}