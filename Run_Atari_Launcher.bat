@echo off
title Atari Game Launcher
echo Starting Atari Game Launcher...
echo.

REM Check if PowerShell script exists
if not exist "%~dp0Dad_Atari_Script.ps1" (
    echo Error: Dad_Atari_Script.ps1 not found!
    echo Please ensure the script is in the same folder as this batch file.
    pause
    exit /b 1
)

REM Run the PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Dad_Atari_Script.ps1"

REM If the script exits with an error, pause to show any error messages
if errorlevel 1 (
    echo.
    echo Script completed with errors. Press any key to exit...
    pause >nul
) else (
    echo.
    echo Script completed successfully.
    timeout /t 2 >nul
) 