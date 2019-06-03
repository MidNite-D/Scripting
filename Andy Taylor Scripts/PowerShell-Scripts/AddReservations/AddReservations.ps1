##### CSV = MAC,IP,NAME (KEEP HEADER)

Param(
	[string]$DHCPServer = "127.0.0.1",
	[string]$DHCPscope = "10.21.44.0",
	[string]$Date = (Get-Date -F yyyy-MM-dd),
	[string]$InputCSV = "C:\Users\administrator.HILLTOP-CURR\Desktop\AddReservations\Book1.csv",
	[string]$log_file = "C:\Users\administrator.HILLTOP-CURR\Desktop\AddReservations\log.txt"
)


function Write-Log
(
	[string]$log,
	[string]$message,
	[string]$delimeter,
	[int]$count
)
{
	if ($delimeter -and $count -gt 0)
	{	Add-Content -Path $log -Value ($delimeter*$count); return
	}
	Add-Content -Path $log -Value ((get-date -format G) + "`t" + $message)
}

# Start logging with some debug info
$os_name = (Get-WmiObject Win32_OperatingSystem).Name.split("|") | Select-Object -First 1
$os_ver = (Get-WmiObject Win32_OperatingSystem).Version
$dot_net_ver = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' | Sort-Object PSChildName -Desc | Select-Object -First 1 -ExpandProperty PSChildName
Write-Log $log_file -Delimeter "-" -Count 100
Write-Log $log_file "Start logging"
Write-Log $log_file "SCRIPT INFO:"
Write-Log $log_file ("- full path`t: " + $MyInvocation.MyCommand.Path)
Write-Log $log_file ("- account`t: " + ([Security.Principal.WindowsIdentity]::GetCurrent()).Name)
Write-Log $log_file "SYSTEM INFO:"
Write-Log $log_file "- computer name`t: $env:computername"
Write-Log $log_file "- OS name`t: $os_name"
Write-Log $log_file "- OS version`t: $os_ver"
Write-Log $log_file "- .NET Framework: $dot_net_ver"
Write-Log $log_file ("- PowerShell`t: v" + $PSVersionTable.PSVersion.ToString())

### Check if 'DHCP Server' role is installed.
Try { Import-Module ServerManager -ErrorAction Stop }
Catch
{
	Write-Host "Unable to load Active Directory module, is RSAT installed?"
	Write-Log $log_file "Tried to load the ServerManager Module, but failed. Is RSAT installed?"; Break
}

Write-Log $log_file "Loaded ServerManager Module."
Write-Log $log_file "Checking if `'DHCP Server`' role is installed on this server."

### Throws Annoying Errors Fix later

##if (-not (Get-WindowsFeature | Where-Object { $_.DisplayName -eq "DHCP Server" -and $_.Installed -eq $True }))
##{
##	Write-Log $log_file "The `'DHCP Server`' role is not installed on this server. Please make sure this script is being run from a server with the `'DHCP Server`' role installed."
##	Exit
#}
###else
##{
##	Write-Log $log_file "Found the `'DHCP Server`' role is installed on this server."
##}

# Assumes a CSV with three columns, MAC, IP and NAME.
Write-Log $log_file "Checking to make sure the CSV file exists for import, File Location: $($InputCSV)"
if (-not (Test-Path $InputCSV))
{
	Write-Warning "CSV File not found. Make sure the file exists, and then re-run the script."
	Write-Log $log_file "CSV File not found. Make sure the file exists, and then re-run the script."
	Start-Sleep -Seconds 10
	Exit
}
else
{
	Write-Log $log_file "CSV File found. Importing CSV file into memory."
	$Computers = Import-CSV $InputCSV
	
	ForEach ($Computer in $Computers)
	{
		Write-Host "Adding reservation for Computer: $($Computer.NAME), with a MAC address: $($Computer.MAC) to DHCP Server: $DHCPServer" -ForegroundColor Yellow -BackgroundColor Black
		Try
		{
			Write-Log $log_file "Adding reservation for Computer: $($Computer.NAME), with a MAC address: $($Computer.MAC) to DHCP Server: $DHCPServer"
			netsh Dhcp Server $DHCPServer Scope $DHCPScope Add reservedip $($Computer.IP) $($Computer.MAC) $($Computer.NAME) $($Computer.NAME) "BOTH"
			Write-Log $log_file "Succeeded in adding a reservation for Computer: $($Computer.NAME), with a MAC address: $($Computer.MAC) to DHCP Server: $DHCPServer"
		}
		Catch
		{
			Write-Log $log_file "Failed to add reservation for Computer: $($Computer.NAME), with a MAC address: $($Computer.MAC) to DHCP Server: $DHCPServer with error: $(error[0])"
		}
	} 
}