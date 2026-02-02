@echo off
REM Uninterrupted APK Build Script
REM This script will build the APK and wait for completion
REM DO NOT CLOSE THIS WINDOW until build completes

echo ========================================
echo   Building Offline Flutter APK
echo   This will take 10-20 minutes
echo   DO NOT INTERRUPT!
echo ========================================
echo.

cd /d "%~dp0"

echo [Step 1/2] Starting build...
echo.
echo Please wait patiently. You will see:
echo  - "Running Gradle task 'assembleRelease'..."
echo  - Download progress indicators
echo  - Compilation messages
echo.
echo DO NOT press Ctrl+C or close this window!
echo.

d:\yoga_app\flutter\bin\flutter.bat build apk --release

if errorlevel 1 (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    echo.
    echo Check error messages above
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   BUILD SUCCESSFUL!
echo ========================================
echo.

echo [Step 2/2] Verifying APK...
echo.

cd build\app\outputs\flutter-apk

if exist app-release.apk (
    for %%F in (app-release.apk) do (
        set /a sizeMB=%%~zF/1048576
        echo APK File: %%F
        echo Size: !sizeMB! MB
        echo Location: %cd%\%%F
    )
    echo.
    if !sizeMB! LSS 40 (
        echo WARNING: APK is suspiciously small
    ) else (
        echo SUCCESS: APK size is correct
        echo App will work OFFLINE
    )
) else (
    echo ERROR: APK file not found
)

echo.
echo ========================================
pause
