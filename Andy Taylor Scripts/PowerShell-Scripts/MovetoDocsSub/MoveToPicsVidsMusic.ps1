$base = 'E:\Curriculum\Users\Pupils\Year 6'
$dir=get-childitem $base
foreach ($d in $dir){

new-Item -ItemType directory -Path $base\$d\Videos
new-Item -ItemType directory -Path $base\$d\Pictures
new-Item -ItemType directory -Path $base\$d\Music
move-item "$base\$d\documents\My Videos\*" $base\$d\Videos
move-item "$base\$d\documents\My Pictures\*" $base\$d\Pictures
move-item "$base\$d\documents\My Music\*" $base\$d\Music

#remove-Item -Path $base\$d\attemp
}
