# 🎵 Rapid Mixer - Fully Functional Release Web App

A complete music stem separation and mixing web application with dual backend architecture for production-ready deployment.

## 🚀 Quick Start

### Option 1: Windows Local Development (Recommended)
```bash
# Double-click or run from command prompt
start-local.bat
```

### Option 2: Docker (Cross-platform)
```bash
# Copy environment variables
cp rapidmixer_2_0/backend/.env.example rapidmixer_2_0/backend/.env
cp rapid-mixer-backend/.env.example rapid-mixer-backend/.env

# Edit .env files with your configuration

# Start all services
docker-compose up --build
```

### Option 3: Manual Setup
```bash
# Audio Processing Backend
cd rapidmixer_2_0/backend
python -m venv venv
venv\Scripts\activate  # On Windows
source venv/bin/activate  # On macOS/Linux
pip install -r requirements.txt
python app.py

# User Management Backend (new terminal)
cd rapid-mixer-backend
npm install
npm start
```

## 📋 Prerequisites

- **Python 3.8+** (for audio processing)
- **Node.js 16+** (for user management)
- **Docker** (optional, for containerized deployment)
- **FFmpeg** (automatically installed via Docker)

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Web   │────│   Nginx Proxy   │────│    Backends     │
│      App        │    │   (Production)  │    │                 │
└─────────────────┘    └─────────────────┘    ├─────────────────┤
                                                   │ Audio Backend  │
                                                   │ (Flask:5000)   │
                                                   ├─────────────────┤
                                                   │ User Backend   │
                                                   │ (Node.js:3000) │
                                                   └─────────────────┘
```

## 🔗 Backend Endpoints

### Audio Processing Backend (`http://localhost:5000`)
- `GET /health` - Health check
- `GET /test-demucs` - Verify Demucs installation
- `POST /upload` - Upload and process audio files
- `GET /separated/<filename>` - Download processed stems

### User Management Backend (`http://localhost:3000`)
- `GET /health` - Health check
- `GET /users` - Get all users
- `POST /users` - Add new user
- `GET /tracks` - Get all tracks
- `POST /tracks` - Add new track
- `GET /` - API documentation

## 🧪 Testing Your Installation

1. **Backend Health Check**: Open `test-backends.html` in your browser
2. **Manual Testing**: Use the provided test HTML page
3. **API Testing**: Use Postman or curl with the endpoints above

## 🐳 Production Deployment

### Docker Compose (Recommended)
```bash
# Production with nginx
docker-compose --profile production up --build
```

### Heroku Deployment
```bash
# Audio Backend
cd rapidmixer_2_0/backend
heroku create rapid-mixer-audio
git add .
git commit -m "Deploy audio backend"
git push heroku main

# User Backend
cd ../../rapid-mixer-backend
heroku create rapid-mixer-users
git add .
git commit -m "Deploy user backend"
git push heroku main
```

## ⚙️ Environment Variables

### Audio Backend (.env)
```bash
DEBUG=false
PORT=5000
UPLOAD_FOLDER=uploads
SEPARATED_FOLDER=separated
MAX_CONTENT_LENGTH=52428800
```

### User Backend (.env)
```bash
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
```

## 🎯 Features Implemented

✅ **Audio Processing**: Complete stem separation using Demucs
✅ **File Upload**: Secure audio file handling (MP3, WAV, FLAC)
✅ **Dual Backend**: Specialized services for different concerns
✅ **Health Monitoring**: Comprehensive health checks
✅ **Error Handling**: Robust error handling and logging
✅ **Production Ready**: Docker, Heroku, and manual deployment
✅ **Cross-Platform**: Windows batch + Docker support
✅ **API Documentation**: Self-documenting endpoints
✅ **File Management**: Automatic cleanup and organization

## 🔧 Troubleshooting

### Common Issues

1. **Demucs Not Found**
   ```bash
   # In audio backend directory
   pip install demucs
   ```

2. **Port Already in Use**
   ```bash
   # Kill processes on ports 5000/3000
   # Windows: netstat -ano | findstr :5000
   # macOS: lsof -ti:5000 | xargs kill -9
   ```

3. **CORS Issues**
   - Both backends have CORS enabled for development
   - Use nginx proxy in production

4. **Memory Issues with Large Files**
   - Adjust `MAX_CONTENT_LENGTH` in .env
   - Ensure sufficient system memory

## 📊 Monitoring

- **Health Checks**: All backends provide `/health` endpoints
- **Logging**: Comprehensive request/response logging
- **File Tracking**: Upload and processing status tracking

## 🔄 Next Steps

1. **Frontend Integration**: Connect your Flutter web app to the backends
2. **Authentication**: Add JWT tokens to secure endpoints
3. **Database**: Integrate Supabase for user management
4. **Storage**: Add cloud storage for processed files
5. **Queue System**: Implement Redis for async processing

## 🆘 Support

- Check the `DEPLOYMENT_GUIDE.md` for detailed instructions
- Use `test-backends.html` to verify installation
- Review logs in terminal windows for error details

---

**Ready for Production!** 🚀

Your Rapid Mixer application is now fully functional and ready for deployment. Use the provided scripts and guides to get started immediately.