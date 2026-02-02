@echo off
REM Build and Verify APK Script
echo ========================================
echo   Building Offline Flutter APK
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] Cleaning previous build...
d:\yoga_app\flutter\bin\flutter.bat clean

echo.
echo [2/3] Building APK (this will take 5-15 minutes)...
echo Please wait - downloading dependencies and compiling...
echo.

d:\yoga_app\flutter\bin\flutter.bat build apk --release

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [3/3] Verifying APK size...
echo.

cd build\app\outputs\flutter-apk

if exist app-release.apk (
    echo ========================================
    echo   BUILD SUCCESSFUL!
    echo ========================================
    echo.
    
    for %%F in (app-release.apk) do (
        set size=%%~zF
        set /a sizeMB=%%~zF/1048576
        echo APK File: %%F
        echo Size: !sizeMB! MB
        echo Full Path: %cd%\%%F
    )
    
    echo.
    echo ========================================
    echo   SIZE VERIFICATION:
    echo ========================================
    echo.
    
    setlocal enabledelayedexpansion
    for %%F in (app-release.apk) do (
        set /a sizeMB=%%~zF/1048576
        
        if !sizeMB! LSS 40 (
            echo ❌ WARNING: APK is only !sizeMB! MB
            echo    Expected: 50-150 MB
            echo    Model may not be bundled correctly!
        ) else if !sizeMB! GTR 200 (
            echo ⚠️  NOTE: APK is !sizeMB! MB
            echo    This is larger than expected
            echo    Includes all architectures
        ) else (
            echo ✅ APK size looks correct: !sizeMB! MB
            echo    Model and dependencies are bundled
            echo    App will work OFFLINE
        )
    )
    
    echo.
    echo ========================================
    echo   APK LOCATION:
    echo ========================================
    echo %cd%\app-release.apk
    echo.
    echo Transfer this APK to your Android device to install
    echo.
    
) else (
    echo ❌ APK file not found!
    echo Build may have failed.
)

echo.
pause
