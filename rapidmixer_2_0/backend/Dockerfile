FROM python:3.9-slim

WORKDIR /app

# Install system dependencies for audio processing
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create upload and separated directories
RUN mkdir -p uploads separated

# Expose port
EXPOSE 5000

# Run the application
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]