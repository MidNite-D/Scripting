notepad
do {$strtime = get-date;write-host $strtime;cls}
until (!(get-process notepad | select -property Responding))
$strtime = get-date;cls
write-host "Notepad closed at $strtime"
