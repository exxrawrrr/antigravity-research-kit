@echo off
setlocal EnableExtensions
title exxrawrrr - Antigravity Research Installer

cd /d "%~dp0"

echo.
echo  ============================================================
echo    exxrawrrr
echo    ANTIGRAVITY x RESEARCH SKILL INSTALLER
echo    made by Rafdi D. Ulhaq
echo  ============================================================
echo.
echo    DO NOT CLOSE THIS WINDOW UNTIL INSTALLATION IS COMPLETE.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
  echo  Installer finished successfully.
) else (
  echo  Installer stopped with exit code %EXIT_CODE%.
  echo  Check the log path printed above.
)
echo.
pause
exit /b %EXIT_CODE%
