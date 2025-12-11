@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell Start-Process -FilePath "%0" -Verb RunAs
    exit /b
)

cls
echo.
echo ░█▀▄░█▀▀░█▀▄░█░░░█▀█░█▀█░▀█▀░█▀▀░█▀▄
echo ░█░█░█▀▀░█▀▄░█░░░█░█░█▀█░░█░░█▀▀░█▀▄
echo ░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀
echo ░█▀▀░█▀▀░█▀▄░▀█▀░█▀█░▀█▀            
echo ░▀▀█░█░░░█▀▄░░█░░█▀▀░░█░            
echo ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░░░░▀░            
echo.
echo by github@fadelhbr
echo.

where adb >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ADB not found in PATH
    echo Please install Android SDK Platform Tools and add to PATH
    pause
    exit /b 1
)

if not exist "list_app.txt" (
    echo ERROR: list_app.txt file not found
    echo This file should contain package names to debloat, one per line
    pause
    exit /b 1
)

set /a app_count=0
for /f "tokens=*" %%p in (list_app.txt) do (
    set "line=%%p"
    if not "!line!"=="" if not "!line:~0,1!"=="#" (
        set /a app_count+=1
    )
)
echo Found %app_count% applications to debloat in list_app.txt

echo Checking for connected devices...
adb devices | findstr "device$" >nul
if %ERRORLEVEL% NEQ 0 (
    echo No devices found. Please connect your device and enable USB debugging.
    echo Make sure to confirm any authorization prompts on your device.
    pause
    exit /b 1
)

set i=0
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b" == "device" (
        set /a i+=1
        set "device_!i!=%%a"
        echo !i!. %%a
    )
)

set selected_device=""
if %i% GTR 1 (
    echo.
    echo Multiple devices found. Please select one:
    set /p device_choice="Enter device number (1-%i%): "
    if !device_choice! LEQ %i% if !device_choice! GEQ 1 (
        set "selected_device=!device_!device_choice!!"
    ) else (
        echo Invalid selection
        pause
        exit /b 1
    )
) else (
    set "selected_device=!device_1!"
)

echo.
echo Selected device: %selected_device%
echo.
echo ===========================================================================
echo WARNING: This script will remove %app_count% applications from your device.
echo This action cannot be easily undone and may affect device functionality.
echo The device will reboot automatically after completion.
echo ===========================================================================
echo.

set /p confirm="Do you want to continue? (y/n): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled by user.
    pause
    exit /b 0
)

echo.
echo Starting debloat process...
echo.

set /a success_count=0
set /a fail_count=0
set /a skipped_count=0

REM
type list_app.txt > temp_packages.txt

REM
for /f "usebackq tokens=*" %%p in ("temp_packages.txt") do (
    set "line=%%p"
    if "!line!"=="" (
        set /a skipped_count+=1
    ) else if "!line:~0,1!"=="#" (
        set /a skipped_count+=1
    ) else (
        call :uninstall_app "%%p" "%selected_device%"
    )
)

REM
del temp_packages.txt >nul 2>&1

echo.
echo Debloat process completed!
echo Successfully removed: %success_count% packages
echo Failed to remove: %fail_count% packages
echo Skipped (comments/empty): %skipped_count% lines
echo.

set /p reboot_choice="Do you want to reboot your device? (y/n): "
if /i "%reboot_choice%"=="y" (
    echo Rebooting device...
    adb -s %selected_device% reboot
    echo Reboot command sent to device.
) else (
    echo Skipping reboot.
)

echo.
echo Script execution completed successfully.
pause
exit /b 0

:uninstall_app
echo Removing %~1...
adb -s %~2 shell pm uninstall -k --user 0 %~1 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Package removed.
    set /a success_count+=1
) else (
    echo [FAILED] Could not remove package. It might be already removed or protected.
    set /a fail_count+=1
)
echo.
goto :eof