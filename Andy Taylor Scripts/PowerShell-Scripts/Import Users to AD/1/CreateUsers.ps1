import-module activedirectory
$Users = Import-Csv -Delimiter "," -Path "c:\adusers\import.csv"
Write-Host $Users
foreach ($User in $Users)  
{  
    $OU = "OU="+$user.year+",OU=test,DC=blackgatescurr,DC=local"  
    $Password = "pass"
    $Detailedname = $User.firstname + " " + $User.lastname 
    $UserFirstname = $User.Firstname 
    #$FirstLetterFirstname = $UserFirstname.substring(0,1) 
    #$SAM =  $FirstLetterFirstname + $User.name 
    $SAM = $user.username
    Write-Host $Detailedname + " " + $SAM
    New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $SAM -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.lastname -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU  
} 