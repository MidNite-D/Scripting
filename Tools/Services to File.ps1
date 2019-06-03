$Services = Get-Service

foreach ($service in $Services) {
    if ($service.status -match "running")  {$Service.Name | Out-File c:\Demo\Running.txt -Append}
    if ($service.status -match "Stopped")  {$Service.Name | Out-File c:\Demo\Stopped.txt -Append}
    
    } 
