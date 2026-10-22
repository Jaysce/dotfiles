@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows11-setup.ps1" %*
set "setupExitCode=%ERRORLEVEL%"
if not "%setupExitCode%"=="0" (
    echo Setup failed. Review the errors above, then run this launcher again.
    pause
)
exit /b %setupExitCode%
