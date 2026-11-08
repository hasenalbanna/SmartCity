@echo off
title Smart City - Flutter Web
color 0B

echo =========================================================
echo       Smart City - Launching Web Application in Chrome
echo =========================================================
echo.

cd /d "%~dp0"

echo [1/3] Checking dependencies...
if not exist "dart_defines.json" (
    echo [!] dart_defines.json not found. Running with default configuration...
    set DART_DEFINES_ARG=
) else (
    echo [*] Found dart_defines.json. Loading environment secrets...
    set DART_DEFINES_ARG=--dart-define-from-file=dart_defines.json
)

echo [2/3] Fetching packages if needed...
call flutter pub get

echo.
echo [3/3] Starting Chrome web instance on http://localhost:8080 ...
echo Press 'r' in this window to hot reload, 'R' to restart, 'q' to quit.
echo.

call flutter run -d chrome --web-port 8080 %DART_DEFINES_ARG%

echo.
echo =========================================================
echo Application session ended.
echo =========================================================
pause
