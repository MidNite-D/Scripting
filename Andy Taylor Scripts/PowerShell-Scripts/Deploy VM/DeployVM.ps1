Param([Parameter(Mandatory=$true)][String]$NewComputerName,[Parameter(Mandatory=$true)][String]$OriginatingVMName,[Parameter(Mandatory=$true)][String]$vSwitchName)     #Add additional params such as memory settings ) 

Write-Verbose "Creating and configuring VM $NewComputerName"

Copy-Item -Path "E:\Resource\VMTemplates\$($OriginatingVMName).VHDX" -Destination "D:\Hyper-V\Virtual Hard Disks\$($NewComputerName)_Disk.vhdx" | Out-Null 

New-VM -Name $NewComputerName -Generation 2 -VHDPath "D:\Hyper-V\Virtual Hard Disks\$($NewComputerName)_Disk.vhdx" -SwitchName $vSwitchName | Out-Null 

Set-VMMemory -VMName $NewComputerName -DynamicMemoryEnabled $True -StartupBytes 1GB -MinimumBytes 1GB -MaximumBytes 6GB 

Set-VMProcessor -VMName $NewComputerName -Count 4 -Reserve 0 -Maximum 100 -RelativeWeight 100   

Write-Verbose "Complete" 