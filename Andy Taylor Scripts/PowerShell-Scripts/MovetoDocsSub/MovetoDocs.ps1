$base = 'E:\Users\Pupils\Year1\test2'
$dir=get-childitem $base
foreach ($d in $dir){

new-Item -ItemType directory -Path $base\$d\attemp
move-item $base\$d\* $base\$d\attemp -force
new-Item -ItemType directory -Path $base\$d\documents
move-item $base\$d\attemp\* $base\$d\documents -force

remove-Item -Path $base\$d\attemp
}
