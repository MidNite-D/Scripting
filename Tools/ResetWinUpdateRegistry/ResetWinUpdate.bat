REM 
REM Stopping Windows Update Services
net stop "wuauserv"
net stop "bits"
net stop "cryptsvc"

reg import \\Gateway\Netlogon\WSUS\ResetWinUpdateRegistry.reg

net start "wuauserv"
net start "bits"
net start "cryptsvc"