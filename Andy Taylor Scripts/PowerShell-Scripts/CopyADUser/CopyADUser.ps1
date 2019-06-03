function createuser(){
#Create User

New-ADUser -SamAccountName $NewUser -Name $NewName -GivenName $firstname -Surname $lastname `
-Instance $DN -Path "$OUDN" -AccountPassword $password -Description $User.description `
-Enabled $true -HomeDirectory $newhome -HomeDrive $User.HomeDrive -DisplayName $NewName -ScriptPath $User.ScriptPath -UserPrincipalName $newprince `
-PasswordNeverExpires $true -CannotChangePassword $false

#Create Home Drive incase of nested folder.

New-Item -Path $newhome -ItemType directory -Force

#Give User Access to Home Folder

$basepath = $newhome -split $NewUser
$path=$basepath[0] + $NewUser + "\"
$acl = (Get-Item $path).GetAccessControl('Access')
$acl.SetAccessRuleProtection($False, $True)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($NewUser,"modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $path $acl

#Add New user to same groups

Get-ADUser -Identity $User -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $NewUser
}




$User = Get-AdUser -Identity (Read-Host "Copy From Username") -Properties *
$DN = $User.distinguishedName
$OldUser = [ADSI]"LDAP://$DN"
$Parent = $OldUser.Parent
$OU = [ADSI]$Parent
$OUDN = $OU.distinguishedName
$password=Read-Host "New Password" -AsSecureString

while($TRUE){
$NewUser = Read-Host "New Username"
$firstname = Read-Host "First Name"
$Lastname = Read-Host "Last Name"
$NewName = "$firstname $lastname"
$newhome = $user.HomeDirectory.Replace($user.SamAccountName, $NewUser)
$newprince = $user.UserPrincipalName.Replace($user.SamAccountName, $NewUser)

createuser

}