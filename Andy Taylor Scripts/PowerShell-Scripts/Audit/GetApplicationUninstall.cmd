@echo off
set target=%1
if not defined target (set target=%computername%)
reg query \\%target%\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s
