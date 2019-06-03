#Create groups in domain up to number¦

for ( $i = 1; $i -le 6; $i++) { 
New-ADGroup -Name "Year$i" -SamAccountName "Year$i" -GroupCategory Security -GroupScope Global -DisplayName "Year$i" -Path "OU=Pupils,OU=Users,OU=Westwood,DC=MidNite,DC=local"
}