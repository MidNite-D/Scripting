$assoc=get-content "c:\users\ataylor\desktop\ass.txt"
foreach ($item in $assoc)
    {
    $command="/c assoc"+"$item"
    write-host $command
    }