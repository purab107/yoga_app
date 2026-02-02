@echo off
echo ========================================
echo Building Yoga App APK
echo ========================================
echo.

cd /d d:\yoga_app\flutter_app
set PATH=C:\flutter_sdk\flutter\bin;%PATH%

echo Cleaning previous build...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building APK (this may take 5-10 minutes)...
call flutter build apk --debug

echo.
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo SUCCESS! APK built successfully!
    echo ========================================
    echo.
    echo APK Location:
    echo d:\yoga_app\flutter_app\build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo You can now transfer this APK to your phone and install it!
    echo.
) else (
    echo ========================================
    echo BUILD FAILED - Please check errors above
    echo ========================================
)

pause
