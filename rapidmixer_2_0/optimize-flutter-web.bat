@echo off
echo Flutter Web Optimization Script
echo =================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Updating Flutter SDK...
flutter upgrade

echo.
echo Cleaning previous builds...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Building web application with optimizations...
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true

echo.
echo Build completed successfully!
echo.
echo Build location: build\web\
echo Bundle size:
for %%i in (build\web\main.dart.js) do @echo %%~zi bytes

echo.
echo Optimization tips:
echo 1. Check for console warnings in browser DevTools
echo 2. Test on multiple browsers
echo 3. Verify service worker functionality
echo 4. Monitor performance metrics

echo.
echo Press any key to open build directory...
pause >nul
start "" build\web