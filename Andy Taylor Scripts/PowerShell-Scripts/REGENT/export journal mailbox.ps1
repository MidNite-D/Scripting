$ranges=@("01/09/2009","02/09/2009","03/09/2010","04/09/2010","05/09/2010","06/09/2010","07/09/2010")

for ($x=1;$x -lt 4;$x++)

{

write-host $ranges[$x] " to " $ranges[$x+1]

$startdate=$ranges[$x]
$enddate=$ranges[$x+1]

export-mailbox "journal" -startdate $startdate -enddate $enddate -targetmailbox "journal export2" -targetfolder "Export" -confirm:$false
$exportfile = "D:\export\Export "+$enddate+".pst"
$exportfile=$exportfile.replace("/","_")
write-host $exportfile
export-mailbox "journal export2" -pstfolderpath $exportfile -deletecontent -confirm:$false

}