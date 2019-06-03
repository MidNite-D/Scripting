$BackupPath = Read-Host "Location of backups ?"
$backups=Get-ChildItem $BackupPath
foreach($backup in $backups){
$backupname=$backup.fullname+"\gpreport.xml"
$Data = [Xml] (Get-Content "$backupname")
New-GPO -Name $data.GPO.Name
Import-GPO -BackupId $backup.Name -Path $Backuppath -TargetName $data.GPO.Name
}

