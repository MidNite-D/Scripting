rename-computer hyperv
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
new-netlbfoteam -Name TEAM -TeamMembers * -TeamingMode SwitchIndependent -Confirm
