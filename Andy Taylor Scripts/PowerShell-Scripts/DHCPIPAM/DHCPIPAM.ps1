Get-DhcpServerv4Reservation -ComputerName w12-app01 -scopeid 172.16.20.0|Select-Object Name,IPAddress,ClientID,Description|Sort-Object IPaddress| ConvertTo-Html|Out-File C:\Users\andy\Desktop\ip.html


