for ( $i = 1; $i -le 8; $i++ ) {
$newpath= "Lesson_$i"
$path= Join-Path C:\Demo -ChildPath $newpath
mkdir $path
}