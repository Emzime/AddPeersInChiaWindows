@echo off
set currentpath=%~dp0
Cmd /C Powershell -file "%currentpath%Scripts\AddNewPeers.ps1"
pause
