$adusers=get-aduser -SearchBase "OU=Pupils new,OU=Users,OU=Millfield,DC=Millfieldcurr,DC=local" -filter *
$folders=get-childitem E:\Users\archive\Pupils

foreach($folder in $folders){
$found=$FALSE
    foreach($user in $adusers){
    if($folder.name -eq $user.samaccountname){
    $found=$TRUE
    write-host $user.name + "Matched"
    $source="E:\Users\archive\Pupils\"+$folder.name
    Move-Item -path $source -Destination E:\Users\Pupils
    break}
    if($found){
    break}
    #else{Write-Host $user.name + "Not Matched"}

    }

}