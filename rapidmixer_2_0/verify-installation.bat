@echo off
echo 🔍 Rapid Mixer Installation Verification
echo =======================================

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
) else (
    echo ✅ Python is installed
    python --version
)

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed or not in PATH
) else (
    echo ✅ Node.js is installed
    node --version
)

REM Check Docker (optional)
docker --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Docker is not installed (optional for production)
) else (
    echo ✅ Docker is installed
    docker --version
)

REM Check FFmpeg (required for audio processing)
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo ❌ FFmpeg is not installed (required for audio processing)
    echo Please install from: https://ffmpeg.org/download.html
) else (
    echo ✅ FFmpeg is installed
)

REM Check file structure
echo.
echo 📁 Checking project structure...
if exist "rapidmixer_2_0\backend\app.py" (
    echo ✅ Audio backend found
) else (
    echo ❌ Audio backend missing
)

if exist "rapid-mixer-backend\index.js" (
    echo ✅ User backend found
) else (
    echo ❌ User backend missing
)

if exist "index.html" (
    echo ✅ Flutter web app found
) else (
    echo ❌ Flutter web app missing
)

echo.
echo 🎯 Summary:
echo - Run 'start-local.bat' to start development
echo - Open 'test-backends.html' to test backends
echo - Run 'deploy-production.bat' for production deployment
echo - Read 'README.md' for complete documentation

echo.
pause