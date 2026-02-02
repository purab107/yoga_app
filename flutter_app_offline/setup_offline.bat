@echo off
REM Setup and run Flutter offline app
echo.
echo ========================================
echo   Flutter Offline App - Setup Script
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Checking Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo [2/4] Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [3/4] Checking TFLite model...
if exist "assets\yoga_model_fp16.tflite" (
    echo ✓ TFLite model found
) else (
    echo ✗ TFLite model NOT found
    echo Please ensure yoga_model_fp16.tflite is in the assets folder
    pause
    exit /b 1
)

echo.
echo [4/4] Setup complete!
echo.
echo ========================================
echo   Ready to run!
echo ========================================
echo.
echo To run the app:
echo   - Android: flutter run
echo   - Build APK: flutter build apk --release
echo.

pause
