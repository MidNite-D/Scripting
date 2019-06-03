clear-host
#### AUTO ELEVATE

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }

function Download-File ($file)
{
Start-BitsTransfer -Source $file -Destination $psscriptroot
}
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host "Downloading Google Chrome Templates"
Write-Host ""
Download-File "https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip"
Write-Host ""
Write-Host "Downloading Server 2016 Templates"
Write-Host ""
Download-File "https://download.microsoft.com/download/0/C/0/0C098953-38C6-4DF7-A2B6-DE10A57A1C55/Windows%2010%20and%20Windows%20Server%202016%20ADMX.msi"
Write-Host ""
Write-Host "Downloading Office 2016 Templates."
Download-File "https://download.microsoft.com/download/2/E/E/2EEEC938-C014-419D-BB4B-D184871450F1/admintemplates_x64_4549-1000_en-us.exe"

Write-Host "Extracting Policy Definitions"
Write-Host ""

$name="Windows%2010%20and%20Windows%20Server%202016%20ADMX.msi"
$folder=$name.Trim(".msi")
start-process -filepath "C:\windows\System32\msiexec" -ArgumentList "/a $psscriptroot\$name /qn TARGETDIR=$PSScriptRoot\Server" -NoNewWindow

$name="admintemplates_x64_4468-1000_en-us.exe"
$folder=$name.Trim(".exe")
start-process -FilePath "$psscriptroot\admintemplates_x64_4549-1000_en-us.exe" -ArgumentList "/quiet /passive /norestart /extract:$PSScriptRoot\Office"

Expand-Archive -Path $PSScriptRoot\policy_templates.zip -DestinationPath $PSScriptRoot\chrome -ErrorAction SilentlyContinue

Write-Host "Moving Templates"

start-process -filepath "Robocopy.exe" -argumentlist "$psscriptroot\chrome\windows\admx C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions /e" -NoNewWindow -wait > $null
start-process -filepath "Robocopy.exe" -argumentlist "$psscriptroot\Office\admx C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions /e" -NoNewWindow -wait > $null
start-process -filepath "Robocopy.exe" -argumentlist "$psscriptroot\Server\PolicyDefinitions C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions /e" -NoNewWindow -wait > $null

write-host "Cleaning Up"

Remove-Item -Path "$psscriptroot\admintemplates_x64_4549-1000_en-us.exe" -Force
Remove-Item -Path "$psscriptroot\policy_templates.zip" -Force
Remove-Item -Path "$psscriptroot\Windows%2010%20and%20Windows%20Server%202016%20ADMX.msi" -Force
Remove-Item -Path "$psscriptroot\chrome" -Recurse -Force
Remove-Item -Path "$psscriptroot\server" -Recurse -Force
Remove-Item -Path "$psscriptroot\office" -Recurse -Force



start-sleep 20







