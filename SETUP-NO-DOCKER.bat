@echo off
chcp 65001 >nul
title SignageCMS - Setup WITHOUT Docker - kishwifi.com
cd /d "%~dp0"

echo.
echo   ============================================================
echo     SignageCMS - Native Setup (NO Docker)
echo     Installs PHP + MariaDB + services right here.
echo     سماع رایانه کیش ^| kishwifi.com
echo   ============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-native.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo   [ERROR] Setup failed. See storage\logs\install.log
    echo.
    pause
)
