@echo off
echo Setting PATH...
set PATH=D:\COLLEGE\Tools\flutter\bin;D:\COLLEGE\Tools\Git\bin;%PATH%
echo PATH set to: %PATH%
echo.
echo Running flutter doctor...
flutter doctor --suppress-analytics
echo.
pause