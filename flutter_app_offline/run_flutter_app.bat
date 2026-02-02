@echo off
cd /d d:\yoga_app\flutter_app
set PATH=C:\flutter_sdk\flutter\bin;%PATH%
echo Starting Flutter Web App on port 8091...
echo.
echo The app will open in Chrome at: http://localhost:8091
echo.
echo IMPORTANT: Keep this window open to keep the app running!
echo To stop the app, close this window or press Ctrl+C
echo.
flutter run -d chrome --web-port 8091
pause
