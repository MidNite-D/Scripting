$path="D:\Hyper-V\Virtual Hard Disks\_TEMPLATE_ Server 2012 R2.vhdx"
Echo "Attempting to Mount $Path" 
Mount-vhd -path $Path -readonly 
Optimize-vhd -path $Path -mode full 
Echo "Attempting to dismount $Path" 
Dismount-vhd -path $Path 