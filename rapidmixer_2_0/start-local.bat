@echo off
echo 🚀 Starting Rapid Mixer Development Environment
echo ==============================================

REM Start Audio Processing Backend
echo 📀 Starting Audio Processing Backend (Flask)...
cd rapidmixer_2_0/backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
start python app.py

REM Wait a moment for Flask to start
timeout /t 5 /nobreak > nul

REM Start User Management Backend
echo 👥 Starting User Management Backend (Node.js)...
cd ..\..\rapid-mixer-backend
npm install
start npm start

echo.
echo ✅ Both backends are starting up...
echo 📊 Audio Backend: http://localhost:5000
echo 📊 User Backend: http://localhost:3000
echo 📊 Health checks available at /health
echo.
echo Press Ctrl+C in this window to close, or close individual terminal windows
echo.
pause