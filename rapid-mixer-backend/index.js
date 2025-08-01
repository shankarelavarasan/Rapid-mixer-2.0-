const express = require("express");
const { createClient } = require("@supabase/supabase-js");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

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
app.get("/tracks", async (req, res) => {
  try {
    const { data, error } = await supabase.from("tracks").select("*");

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

app.post("/tracks", async (req, res) => {
  try {
    const { title, artist, duration, file_url } = req.body;

    if (!title || !file_url) {
      return res.status(400).json({ error: "Title and file_url are required" });
    }

    const { data, error } = await supabase
      .from("tracks")
      .insert([{ title, artist, duration, file_url, created_at: new Date().toISOString() }])
      .select();

    if (error) {
      console.error("Database error:", error);
      return res.status(500).json({ error: error.message });
    }

    res.status(201).json({
      success: true,
      data: data[0]
    });
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({ error: "Internal server error" });
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
