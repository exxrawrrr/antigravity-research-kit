@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul 2>&1
title exxrawrrr - Repair Antigravity Research Kit

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\install.ps1" -NoPause %*
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" goto :done

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\verify.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

:done
if not "%EXIT_CODE%"=="0" (
  echo.
  echo  [FAIL] Repair or final verification returned exit code %EXIT_CODE%.
)

if not defined CI if not "%ARK_NO_PAUSE%"=="1" (
  echo.
  pause
)

exit /b %EXIT_CODE%
