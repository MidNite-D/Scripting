while($TRUE){
    $day=(get-date).DayOfWeek.value__
    [int]$hour = get-date -format HH
    $day
    $hour
    if(($day -lt 6) -and ($day -gt 0)){
        Write-Host "Weekday"
        if(($hour -gt 22) -or ($hour -lt 16)){
            write-host "Outside Peak Hours"
            $gdrive = Get-Process gdrive -ErrorAction SilentlyContinue
            if($gdrive -eq $null){
                Write-host "gDrive not running - starting sync"
                $args = "sync upload e:\Media\Video\Films 0B6N5zCZfpl1zaWJpOW9ZMkFFMzA"
                Start-Process "c:\program files\gdrive\gdrive.exe" -ArgumentList $args
            }
                else{
                    Write-host "gDrive already running"
                }
           
        }
        else{
            Write-Host "Peak Time"
            $gdrive = Get-Process gdrive -ErrorAction SilentlyContinue
            $gdrive
            if($gdrive -eq $null){
            Write-host "gDrive not running."
            }
            else{
                Write-host "gDrive is running, shutting down."   
                get-process gdrive | Stop-Process    
            }
        }
    }
    else{
        Write-Host "Weekend"
        if(($hour -gt 22) -or ($hour -lt 11)){
            write-host "Outside Peak Hours"
            $gdrive = Get-Process gdrive -ErrorAction SilentlyContinue
            if($gdrive -eq $null){
                Write-host "gDrive not running - starting sync"
                $args = "sync upload e:\Media\Video\Films 0B6N5zCZfpl1zaWJpOW9ZMkFFMzA"
                Start-Process "c:\program files\gdrive\gdrive.exe" -ArgumentList $args
            }
                else{
                    Write-host "gDrive already running"
                }
           
        }
        else{
            Write-Host "Peak Time"
            $gdrive = Get-Process gdrive -ErrorAction SilentlyContinue
            $gdrive
            if($gdrive -eq $null){
            Write-host "gDrive not running."
            }
            else{
                Write-host "gDrive is running, shutting down."   
                get-process gdrive | Stop-Process    
            }
        }

    }
    
    Start-Sleep 60

}
