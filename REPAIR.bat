@echo off
setlocal EnableExtensions
title exxrawrrr - Repair Antigravity Research Kit
cd /d "%~dp0"

echo.
echo  ============================================================
echo    exxrawrrr - REPAIR MODE
echo    made by Rafdi D. Ulhaq
echo  ============================================================
echo.
echo    Existing healthy components will be SKIPPED.
echo    Managed settings are backed up before rewrite.
echo    DO NOT CLOSE THIS WINDOW UNTIL REPAIR IS COMPLETE.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1" -NoPause
if errorlevel 1 goto :failed

echo.
echo  Running final verification...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\verify.ps1"
set "EXIT_CODE=%ERRORLEVEL%"
goto :done

:failed
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo  Repair installer failed. Verification was not run.

:done
echo.
pause
exit /b %EXIT_CODE%
