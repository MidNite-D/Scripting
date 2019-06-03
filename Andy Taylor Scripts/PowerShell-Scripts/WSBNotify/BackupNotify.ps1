### Connect Up Windows Server Backup Notification Script ###
### AT - 10/6/15
### Sort results by event time/date - 8/9/15

### Set options here ######################################################################################

$School="SchoolName" ## No Spaces
$path="InstallPath" ## Script Location
$Recipient="ConnectAddress" 
$SMTP="mailgate.connect-up.co.uk"

###########################################################################################################

$SendAddress="$School@ConnectWSB.com"

$lastbackup=(get-date) - (New-TimeSpan -day 1) 
$nl = [Environment]::NewLine

$page=Get-Content "$path\PageHeader.txt"
$page=$page+$nl

$report = Get-WinEvent -LogName "Microsoft-Windows-Backup"|where {$_.timecreated -gt $lastbackup}|select-object machinename,timecreated,message|sort-object timecreated|ConvertTo-Html -Fragment
$page=$page+$report+$nl
$page=$page+"<br>"+$nl

Remove-Item $path\Backupstatus.html
$page|Out-File $path\Backupstatus.html
$body= (Get-Content $path\Backupstatus.html | out-string )
Send-MailMessage -from $SendAddress -to $recipient -Subject "$School Backup Notification" -Body $body -SMTPServer $SMTP -BodyAsHtml
