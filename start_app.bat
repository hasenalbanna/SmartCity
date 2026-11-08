@echo off
title Smart City - Flutter Web
color 0B

echo =========================================================
echo       Smart City - Launching Web Application in Chrome
echo =========================================================
echo.

cd /d "%~dp0"

echo [1/2] Checking configuration...
if not exist "dart_defines.json" (
    echo [!] dart_defines.json not found. Running with default configuration...
    set DART_DEFINES_ARG=
) else (
    echo [*] Found dart_defines.json. Loading environment secrets...
    set DART_DEFINES_ARG=--dart-define-from-file=dart_defines.json
)

echo.
echo [2/2] Starting Flutter on Chrome...
echo Press 'r' in this window to hot reload, 'R' to restart, 'q' to quit.
echo.

call flutter run -d chrome --web-port=0 %DART_DEFINES_ARG%

echo.
echo =========================================================
echo Application session ended.
echo =========================================================
pause
