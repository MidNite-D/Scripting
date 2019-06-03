import-module activedirectory
$Users = Import-Csv -Delimiter "," -Path "c:\Holyfamily\year1.csv"
Write-Host $Users
foreach ($User in $Users)  
{  
    $OU = "OU="+$user.year+",OU=Pupils,OU=Users,OU=HolyFamily,DC=holyfamilycurr,DC=local"  
    $Password = "pupil"
    $Detailedname = $User.forename + " " + $User.surname 
    $Userforename = $User.forename 
    #$FirstLetterforename = $Userforename.substring(0,1) 
    #$SAM =  $FirstLetterforename + $User.name 
    $SAM = $user.username
    Write-Host $Detailedname + " " + $SAM
    New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $SAM -DisplayName $Detailedname -GivenName $user.forename -Surname $user.surname -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU  
} 