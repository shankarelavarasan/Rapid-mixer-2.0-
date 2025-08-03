#!/bin/bash

echo "🚀 Starting Rapid Mixer Development Environment"
echo "=============================================="

# Start Audio Processing Backend
echo "📀 Starting Audio Processing Backend (Flask)..."
cd rapidmixer_2_0/backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py &
AUDIO_PID=$!

# Wait a moment for Flask to start
sleep 5

# Start User Management Backend
echo "👥 Starting User Management Backend (Node.js)..."
cd ../../rapid-mixer-backend
npm install
npm start &
NODE_PID=$!

echo ""
echo "✅ Both backends are starting up..."
echo "📊 Audio Backend: http://localhost:5000"
echo "📊 User Backend: http://localhost:3000"
echo "📊 Health checks available at /health"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for interrupt
wait $AUDIO_PID $NODE_PID

# Cleanup function for Ctrl+C
trap 'kill $AUDIO_PID $NODE_PID; exit' INT

wait