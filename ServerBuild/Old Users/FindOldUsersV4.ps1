## --------- Fill this bit in
$days="-120" # must be nagative number
$disable="no"  # test for old accounts without disabling - logged to console and file
$move="no"  # move accounts do the disabled OU?
$description = "Disabled by AT on $date."
$CheckFolderSize = "yes" # Determine space used by accounts.

$ou = "OU=Staff,DC=nwsilc,DC=local"  # OU to search for accounts
$disabledOU = "OU=Disabled Accounts,OU=Staff,DC=nwsilc,DC=local" # OU to move disbaled accounts to
$logfile = "C:\disabled.csv" # make sure script has write permission if you want a log.
$UserDataPath="E:\staff\staffprivate" # base direcetory for user data.
$ArchiveDataPath="D:\Users\ARCHIVE\Staff" # directory to archive data to.
##=====================================================================


$date = Get-Date
$data = 0

write-host -foregroundcolor yellow "Searching for old user accounts."

$finduser = Get-aduser –filter * -SearchBase $ou -properties cn,lastlogondate | Sort-Object CN | Where-Object {$_.LastLogonDate –le [DateTime]::Today.AddDays($days) -and ($_.lastlogondate -ne $null)}

$finduser | export-csv $logfile

foreach($user in $finduser){
    $username=$user.SamAccountName
        if($CheckFolderSize -eq "yes"){
            if(test-path $UserDataPath\$username){
                $usersize = (Get-ChildItem $UserDataPath\$username -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB
                $usermb = "{0:N2} MB" -f $usersize
                write-host -foregroundcolor red $user.CN $usermb
                $data += $usersize}}
        else {
            write-host $user.CN -foregroundcolor red}}

write-host "Found "$finduser.count " accounts."
$data="{0:N2} MB" -f $data
write-host $data

if($disable -eq "yes")
{
write-host -foregroundcolor yellow "Disabling old user accounts."
$finduser | set-aduser -Description $description –passthru | Disable-ADAccount
}

if($move -eq "yes")
{
write-host -foregroundcolor yellow "Searching OU for disabled Accounts"
[System.Threading.Thread]::Sleep(500)
$disabledAccounts = Search-ADAccount -AccountDisabled -UsersOnly -SearchBase $ou

write-host -foregroundcolor yellow "Moving disabled Accounts to the disabled OU"
[System.Threading.Thread]::Sleep(500)
$disabledAccounts | Move-ADObject -TargetPath $disabledOU
}
if($move -eq "yes")
{
write-host -ForegroundColor yellow "Moving User Data"
[System.Threading.Thread]::Sleep(500)

foreach($user in $finduser){
write-host -foregroundcolor red $user.CN
$username=$user.SamAccountName
Move-Item $UserDataPath\$username $ArchiveDataPath\$username
}
}
write-host -foregroundcolor yellow "Script Complete."