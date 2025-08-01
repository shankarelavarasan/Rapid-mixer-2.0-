@echo off
echo 🚀 Rapid Mixer Production Deployment
echo =====================================

REM Production deployment script for Windows
echo.
echo Available deployment options:
echo 1. Docker Compose (Recommended)
echo 2. Heroku Deployment
echo 3. Manual Setup
echo.

set /p choice="Choose deployment option (1-3): "

if "%choice%"=="1" (
    echo 📦 Starting Docker deployment...
    
    REM Check if Docker is running
    docker --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Docker is not installed or not running
        pause
        exit /b
    )
    
    echo 🔧 Building and starting containers...
    docker-compose up --build
    
) else if "%choice%"=="2" (
    echo 🌐 Starting Heroku deployment...
    
    REM Check if Heroku CLI is installed
    heroku --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Heroku CLI is not installed
        echo Please install from: https://devcenter.heroku.com/articles/heroku-cli
        pause
        exit /b
    )
    
    echo 📱 Deploying Audio Backend...
    cd rapidmixer_2_0/backend
    git init
    git add .
    git commit -m "Initial audio backend deployment"
    heroku create rapid-mixer-audio-%random%
    git push heroku main
    
    echo 👥 Deploying User Backend...
    cd ../../rapid-mixer-backend
    git init
    git add .
    git commit -m "Initial user backend deployment"
    heroku create rapid-mixer-users-%random%
    git push heroku main
    
    echo ✅ Heroku deployment complete!
    echo 📊 Audio Backend: https://rapid-mixer-audio-*.herokuapp.com
    echo 📊 User Backend: https://rapid-mixer-users-*.herokuapp.com
    
) else if "%choice%"=="3" (
    echo 🔧 Starting manual deployment...
    echo Please follow the instructions in DEPLOYMENT_GUIDE.md
    start DEPLOYMENT_GUIDE.md
) else (
    echo ❌ Invalid choice. Please run the script again.
)

pause