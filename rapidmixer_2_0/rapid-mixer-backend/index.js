const express = require('express');
const { createClient } = require("@supabase/supabase-js");
const cors = require("cors");
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require("dotenv").config();
const winston = require('winston');

// Configure logging
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'rapid-mixer-backend' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply rate limiting to all requests
app.use(limiter);

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path} - ${req.ip}`);
  next();
});

// Supabase client create
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Simple test route
app.get("/", async (req, res) => {
  res.json({
    message: "Rapid Mixer Backend is Running!",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      users: "/users",
      tracks: "/tracks"
    }
  });
});

// Enhanced Supabase query route
app.get("/users", async (req, res) => {
  try {
    const { data, error } = await supabase.from("users").select("*");

    if (error) {
      console.error("Database error:", error);
      return res.status(500).json({ error: error.message });
    }
    
    res.json({
      success: true,
      count: data.length,
      data: data
    });
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Tracks endpoints
// Validation middleware
const validateTrack = (req, res, next) => {
  const { title, artist, file_url, duration } = req.body;
  const errors = [];

  if (!title || typeof title !== 'string' || title.trim().length === 0) {
    errors.push('Title is required and must be a non-empty string');
  }

  if (!artist || typeof artist !== 'string' || artist.trim().length === 0) {
    errors.push('Artist is required and must be a non-empty string');
  }

  if (!file_url || typeof file_url !== 'string' || !file_url.startsWith('http')) {
    errors.push('Valid file_url is required');
  }

  if (duration && (typeof duration !== 'number' || duration < 0)) {
    errors.push('Duration must be a positive number');
  }

  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  next();
};

// GET /tracks - Get all tracks with pagination and filtering
app.get('/tracks', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 50, 100); // Max 100 items
    const offset = (page - 1) * limit;
    const search = req.query.search;

    let query = supabase.from('tracks').select('*', { count: 'exact' });

    if (search) {
      query = query.or(`title.ilike.%${search}%,artist.ilike.%${search}%`);
    }

    query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1);

    const { data, error, count } = await query;
    
    if (error) {
      logger.error('Error fetching tracks:', error);
      return res.status(400).json({ error: error.message });
    }
    
    res.json({ 
      tracks: data || [], 
      pagination: {
        page,
        limit,
        total: count,
        totalPages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    logger.error('Server error in GET /tracks:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/tracks', validateTrack, async (req, res) => {
  try {
    const { title, artist, file_url, duration, genre, album } = req.body;
    
    const trackData = {
      title: title.trim(),
      artist: artist.trim(),
      file_url: file_url.trim(),
      duration: duration || 0,
      genre: genre?.trim() || null,
      album: album?.trim() || null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const { data, error } = await supabase.from('tracks').insert([trackData]).select();
    
    if (error) {
      logger.error('Error adding track:', error);
      return res.status(400).json({ error: error.message });
    }
    
    logger.info(`Track added: ${title} by ${artist}`);
    res.status(201).json({ 
      message: 'Track added successfully', 
      track: data[0] 
    });
  } catch (error) {
    logger.error('Server error in POST /tracks:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error("Unhandled error:", error);
  res.status(500).json({ error: "Something went wrong" });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📁 API endpoints: http://localhost:${PORT}`);
});
