@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if defined WT_SESSION goto :run_here

where wt.exe >nul 2>&1
if not errorlevel 1 (
  start "" wt.exe -w new -M -f new-tab --title "exxrawrrr - Antigravity Research Installer" -d "%CD%" powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\start.ps1" %*
  exit /b 0
)

:run_here
chcp 65001 >nul
title exxrawrrr - Antigravity Research Installer
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer\start.ps1" %*
exit /b %ERRORLEVEL%
