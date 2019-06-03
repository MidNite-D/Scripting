### Generate HTML Status Page ###

### Set options here ######################################################################################

# List of servers to check
$servers="Sharepoint01","Gateway2012","Exchange1","Servicedesk2012","SQL01","WebApp01","WDS","Fileserver"
# Path to save report
$path="\\sharepoint01\C$\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\template\layouts"

###########################################################################################################

$lastbackup=(get-date) - (New-TimeSpan -day 1) 
$nl = [Environment]::NewLine

$page=Get-Content c:\BackupReports\PageHeader.txt
$page=$page+$nl

foreach ($server in $servers)
{
$server
$report = Get-WinEvent -computername $server -LogName "Microsoft-Windows-Backup"|where {$_.timecreated -gt $lastbackup}|select-object machinename,timecreated,message|sort-object timecreated|ConvertTo-Html -Fragment
$page=$page+$report+$nl
$page=$page+"<br>"+$nl
}
Remove-Item $path\Backupstatus.html
$page|Out-File $path\Backupstatus.html