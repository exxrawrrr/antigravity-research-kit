@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0VERIFY.bat" %*
exit /b %ERRORLEVEL%
