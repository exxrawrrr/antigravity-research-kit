@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul 2>&1
title exxrawrrr - Verify Antigravity Research Kit

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\verify.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo  [FAIL] Verification found incomplete or unhealthy components.
  echo         Run REPAIR.bat after reviewing the messages above.
)

if not defined CI if not "%ARK_NO_PAUSE%"=="1" (
  echo.
  pause
)

exit /b %EXIT_CODE%
