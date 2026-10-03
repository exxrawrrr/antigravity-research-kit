@echo off
setlocal EnableExtensions
title exxrawrrr - Verify Antigravity Research Kit
cd /d "%~dp0"

echo.
echo  ============================================================
echo    exxrawrrr - VERIFY INSTALLATION
echo    made by Rafdi D. Ulhaq
echo  ============================================================
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\verify.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
  echo  Verification PASSED.
) else (
  echo  Verification found incomplete or unhealthy components.
  echo  Run REPAIR.bat after reviewing the messages above.
)
echo.
pause
exit /b %EXIT_CODE%
