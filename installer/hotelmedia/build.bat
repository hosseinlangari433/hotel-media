@echo off
chcp 65001 >nul
title ساخت Setup-HotelMedia.exe
cd /d "%~dp0"

echo.
echo   ============================================================
echo     ساخت نصب‌کننده هتل مدیا  (Setup-HotelMedia.exe)
echo     سماع رایانه کیش ^| kishwifi.com
echo   ============================================================
echo.
echo   در حال ساخت... (دانلود PHP/MariaDB فقط بار اول انجام می‌شود)
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-hotelmedia.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo   [خطا] ساخت ناموفق بود.
    echo   مطمئن شوید Inno Setup 6 نصب است:  https://jrsoftware.org/isdl.php
    echo.
    pause
    exit /b 1
)

echo.
echo   فایل آماده شد:  installer\hotelmedia\Output\Setup-HotelMedia.exe
echo.
pause
