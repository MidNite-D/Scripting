$users = Get-ChildItem C:\Users
foreach ($user in $users){
$folder = "$($user.fullname)\AppData\Local\Microsoft\Windows\Temporary Internet Files"
   If (Test-Path $folder) {
     Remove-Item $folder -Recurse -Force -ErrorAction silentlycontinue 
   }
}