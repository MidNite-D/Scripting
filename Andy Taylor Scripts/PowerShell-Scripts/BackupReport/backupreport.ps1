### Check Office Backups and Email Report ###

### Set options here ######################################################################################

# Recipient address
$recipient="admins@connect-up.co.uk"
# List of servers to check
$servers="Sharepoint01","Gateway2012","Exchange1","Servicedesk2012","SQL01","WebApp01","WDS","Fileserver"
# Path to script
$path="c:\backupreports"

###########################################################################################################

$Header="Backup Results from "+ $lastbackup.Date
$lastbackup=(get-date) - (New-TimeSpan -day 1) 
$header > $path\BackupReport.txt
foreach ($server in $servers)
{
$log = Get-WinEvent -computername $server -LogName "Microsoft-Windows-Backup"|where {$_.timecreated -gt $lastbackup}|sort-object TimeCreated |Format-Table TimeCreated, Message -AutoSize -Wrap
$server >> $path\BackupReport.txt
$log >> $path\BackupReport.txt
}

$body= (Get-Content $path\BackupReport.txt | out-string )
Send-MailMessage -from backups@connect-up.co.uk -to $recipient -Subject "Office Backups" -Body $body -SMTPServer exchange1.cuss.local -Attachments $path\BackupReport.txt
