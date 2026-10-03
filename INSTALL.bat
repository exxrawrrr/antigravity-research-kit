@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul 2>&1
title exxrawrrr - Antigravity Research Installer

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo  [FAIL] Installer stopped with exit code %EXIT_CODE%.
  echo         Review the log path printed by the installer above.
)

if not defined CI if not "%ARK_NO_PAUSE%"=="1" (
  echo.
  pause
)

exit /b %EXIT_CODE%
