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

$installdirectory="c:\program files\LicenseManager"

### download exe
$executable=$PSScriptRoot+"\executable"
$source = "http://files.404.me.uk/repo/executable"
$username = "404repo"
$password = "255820MonkeyBalls"  | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username,$password)
Invoke-WebRequest $source -OutFile $executable -Credential $cred

### create DNS record

$domain=Get-ADDomain
$fqdn=$domain.PDCEmulator
$domainname=$domain.DNSRoot
Add-DnsServerResourceRecord -ZoneName $domainname -Name _VLMCS._tcp -Srv -DomainName $fqdn -Port 1688 -Priority 0 -Weight 0 -ComputerName $fqdn -Verbose

### create service


if (!(Test-Path -path $installdirectory)) {New-Item $installdirectory -Type Directory}
Copy-Item $executable -Destination "$installdirectory\LicenseManager.exe"
New-Service -Name "License Manager" -BinaryPathName "$installdirectory\LicenseManager.exe" -DisplayName "License Manager" -StartupType Automatic -Description "License Manager Service."
Start-Service "License Manager"
Remove-Item $executable -Force




