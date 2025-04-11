@echo off
setlocal enabledelayedexpansion

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell Start-Process -FilePath "%0" -Verb RunAs
    exit /b
)

cls
echo
echo ░█▀▄░█▀▀░█▀▄░█░░░█▀█░█▀█░▀█▀░█▀▀░█▀▄
echo ░█░█░█▀▀░█▀▄░█░░░█░█░█▀█░░█░░█▀▀░█▀▄
echo ░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀
echo ░█▀▀░█▀▀░█▀▄░▀█▀░█▀█░▀█▀            
echo ░▀▀█░█░░░█▀▄░░█░░█▀▀░░█░            
echo ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░░░░▀░            
echo
echo by github@fadelhbr

where adb >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ADB not found in PATH
    echo Please install Android SDK Platform Tools and add to PATH
    pause
    exit /b 1
)

if not exist "list_app.txt" (
    echo ERROR: list_app.txt file not found
    echo This file should contain package names to reinstall, one per line
    pause
    exit /b 1
)

set /a app_count=0
for /f "tokens=*" %%p in (list_app.txt) do (
    set /a app_count+=1
)
echo Found %app_count% applications to restore in list_app.txt

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
echo ==============================================================================
echo This script will try to restore %app_count% previously debloated applications.
echo Note: MakesureMake sure the device is properly connected. 
echo ==============================================================================
echo.

set /p confirm="Do you want to continue? (y/n): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled by user.
    pause
    exit /b 0
)

echo.
echo =============================================================================
echo Starting restore process...
echo =============================================================================
echo.

set /a success_count=0
set /a fail_count=0

for /f "tokens=*" %%p in (list_app.txt) do (
    call :reinstall_app "%%p" "%selected_device%"
)

echo.
echo ============================================================================
echo Restore process completed!
echo Successfully restored: %success_count% packages
echo Failed to restore: %fail_count% packages
echo ============================================================================
echo.
echo Note: You may need to reboot your device for all changes to take effect.
pause
exit /b 0

:reinstall_app
echo Restoring %~1...
adb -s %~2 shell cmd package install-existing %~1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Package restored.
    set /a success_count+=1
) else (
    echo [FAILED] Could not restore package. It might be a non-system app.
    set /a fail_count+=1
)
echo.
goto :eof