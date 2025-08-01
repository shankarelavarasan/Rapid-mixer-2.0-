# Rapid Mixer - Production Deployment Guide

## Overview
This guide will help you deploy the Rapid Mixer application as a fully functional web app with both audio processing and user management capabilities.

## Project Structure
```
rapid-mixer-backend/          # Node.js + Supabase backend
├── index.js               # Main server file
├── package.json           # Dependencies
├── Procfile              # Heroku deployment
├── .env.example          # Environment variables template
└── ...

rapidmixer_2_0/backend/    # Python Flask audio processing backend
├── app.py                # Main Flask application
├── requirements.txt      # Python dependencies
├── Dockerfile           # Container deployment
├── Procfile             # Heroku deployment
├── .env.example         # Environment variables template
└── ...
```

## Backend Services

### 1. Audio Processing Backend (Flask)
**Location:** `rapidmixer_2_0/backend/`

**Features:**
- Audio file upload and storage
- Stem separation using Demucs
- Download separated audio tracks
- Health monitoring endpoints
- Error handling and validation

**Quick Start:**
```bash
cd rapidmixer_2_0/backend/
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your configuration
python app.py
```

**Environment Variables:**
- `DEBUG`: Debug mode (true/false)
- `PORT`: Server port (default: 5000)
- `UPLOAD_FOLDER`: Path for uploaded files
- `SEPARATED_FOLDER`: Path for processed stems
- `MAX_CONTENT_LENGTH`: Max file size in bytes

### 2. User Management Backend (Node.js + Supabase)
**Location:** `rapid-mixer-backend/`

**Features:**
- User management via Supabase
- Track metadata storage
- RESTful API endpoints
- Health checks and monitoring
- CORS enabled for web apps

**Quick Start:**
```bash
cd rapid-mixer-backend/
npm install
cp .env.example .env
# Edit .env with your Supabase credentials
npm start
```

**Environment Variables:**
- `PORT`: Server port (default: 3000)
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_KEY`: Your Supabase anon key

## Deployment Options

### Option 1: Heroku Deployment (Recommended)

#### Deploy Audio Processing Backend
```bash
cd rapidmixer_2_0/backend/
heroku create your-audio-backend-name
heroku config:set DEBUG=false
heroku config:set MAX_CONTENT_LENGTH=52428800  # 50MB
git add .
git commit -m "Deploy audio processing backend"
git push heroku main
```

#### Deploy User Management Backend
```bash
cd rapid-mixer-backend/
heroku create your-user-backend-name
heroku config:set SUPABASE_URL=your_supabase_url
heroku config:set SUPABASE_KEY=your_supabase_key
git add .
git commit -m "Deploy user management backend"
git push heroku main
```

### Option 2: Docker Deployment

#### Build and Run Audio Processing Backend
```bash
cd rapidmixer_2_0/backend/
docker build -t rapid-mixer-audio .
docker run -p 5000:5000 \
  -e DEBUG=false \
  -e MAX_CONTENT_LENGTH=52428800 \
  -v $(pwd)/uploads:/app/uploads \
  -v $(pwd)/separated:/app/separated \
  rapid-mixer-audio
```

### Option 3: Local Production Setup

#### Audio Processing Backend
```bash
cd rapidmixer_2_0/backend/
pip install gunicorn
gunicorn app:app --bind 0.0.0.0:5000 --workers 4
```

#### User Management Backend
```bash
cd rapid-mixer-backend/
npm start
# Or with PM2 for production:
npm install -g pm2
pm2 start index.js --name "rapid-mixer-api"
```

## API Endpoints

### Audio Processing Backend (`/api/audio`)
- `POST /upload` - Upload audio file
- `GET /separated/<filename>` - Download separated stems
- `GET /health` - Health check
- `GET /test-demucs` - Test Demucs installation

### User Management Backend (`/api/users`)
- `GET /health` - Health check
- `GET /users` - Get all users
- `GET /tracks` - Get all tracks
- `POST /tracks` - Create new track

## Frontend Integration

### Update Frontend API URLs
In your Flutter web app, update the API endpoints to point to your deployed backends:

```javascript
// Example configuration
const API_CONFIG = {
  audioBackend: 'https://your-audio-backend.herokuapp.com',
  userBackend: 'https://your-user-backend.herokuapp.com'
};
```

### CORS Configuration
Both backends are configured with CORS enabled for web deployment. No additional changes needed.

## Monitoring

### Health Checks
- Audio Backend: `https://your-audio-backend.herokuapp.com/health`
- User Backend: `https://your-user-backend.herokuapp.com/health`

### Logs
- Heroku: `heroku logs --tail`
- Docker: `docker logs container_name`
- PM2: `pm2 logs rapid-mixer-api`

## Troubleshooting

### Common Issues

1. **Large file uploads fail**
   - Increase `MAX_CONTENT_LENGTH` in environment variables
   - Check Heroku limits (max 500MB on paid plans)

2. **Demucs processing fails**
   - Ensure sufficient memory (minimum 2GB RAM recommended)
   - Check `/test-demucs` endpoint for installation issues

3. **Database connection errors**
   - Verify Supabase credentials
   - Check network connectivity
   - Ensure proper CORS configuration

4. **Port binding issues**
   - Use environment variables for port configuration
   - Ensure no other services are using the same port

## Production Checklist

- [ ] Environment variables configured
- [ ] Health check endpoints tested
- [ ] File upload limits set appropriately
- [ ] SSL certificates configured (Heroku provides automatically)
- [ ] Monitoring and alerting set up
- [ ] Backup strategy for user data
- [ ] Rate limiting configured (if needed)
- [ ] Error handling tested
- [ ] Frontend API URLs updated
- [ ] Performance testing completed

## Support

For deployment issues:
1. Check the health endpoints
2. Review application logs
3. Verify environment variables
4. Test endpoints with curl/Postman
5. Check resource usage on hosting platform