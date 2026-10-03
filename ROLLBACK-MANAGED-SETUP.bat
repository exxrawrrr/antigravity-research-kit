@echo off
setlocal EnableExtensions
title exxrawrrr - Rollback Managed Antigravity Research Setup
cd /d "%~dp0"

echo.
echo  ============================================================
echo    EXXRAWRRR - MANAGED SETUP ROLLBACK
echo    made by Rafdi D. Ulhaq
echo  ============================================================
echo.
echo  This restores installer-managed settings/PATH and removes:
echo    - agy-safe launcher
echo    - Rafdi Academic Research Pack
echo.
echo  It DOES NOT uninstall Antigravity apps or third-party extensions.
echo.
set /p "CONFIRM=Type ROLLBACK to continue: "
if /I not "%CONFIRM%"=="ROLLBACK" (
  echo.
  echo  Cancelled. Nothing changed.
  pause
  exit /b 0
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\rollback.ps1" -ConfirmRollback
set "EXIT_CODE=%ERRORLEVEL%"

echo.
pause
exit /b %EXIT_CODE%
