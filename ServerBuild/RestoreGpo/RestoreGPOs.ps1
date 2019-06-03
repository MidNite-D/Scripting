$BackupPath = Read-Host "Location of backups ?"
$backups=Get-ChildItem $BackupPath
foreach($backup in $backups){
$backuppath=$backup.fullname+"\gpreport.xml"
$Data = [Xml] (Get-Content "$backuppath")
New-GPO -Name $data.GPO.Name
Import-GPO -BackupId $backup.Name -Path $BackupPath -TargetName $data.GPO.Name
}

