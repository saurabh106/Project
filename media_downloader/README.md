# Universal Media Downloader Backend

A FastAPI-based backend service for downloading media from YouTube using yt-dlp.



## 📋 Prerequisites

- Python 3.8+ **OR** Docker
- FFmpeg (optional, for audio conversion)

## 🛠️ Installation & Setup

### Method 1: Using Docker (Recommended)

#### Step 1: Build the Docker Image
```bash
# Navigate to backend directory
cd backend

# Build the image
docker build -t universal-media-downloader .

# Or with a specific version
docker build -t universal-media-downloader:3.1.0 .
```

#### Step 2: Run the Container
```bash
# Basic run
docker run -d -p 8000:8000 --name media-downloader universal-media-downloader

# Run with persistent storage
mkdir downloads
docker run -d \
  -p 8000:8000 \
  -v $(pwd)/downloads:/app/temp_downloads \
  --name media-downloader \
  universal-media-downloader

# Run with custom port
docker run -d -p 8080:8000 --name media-downloader universal-media-downloader
```

#### Step 3: Verify Installation
```bash
# Check if container is running
docker ps

# Check logs
docker logs media-downloader

# Test the application
curl http://localhost:8000/api/health
```

### Method 2: Manual Python Installation

#### Step 1: Setup Python Environment
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate
```

#### Step 2: Install Dependencies
```bash
# Install Python packages
pip install -r requirements.txt
```

#### Step 3: Install FFmpeg (Recommended)
- **Ubuntu/Debian**: `sudo apt install ffmpeg`
- **macOS**: `brew install ffmpeg`
- **Windows**: Download from [FFmpeg official site](https://ffmpeg.org/)

#### Step 4: Run the Application
```bash
python main.py
```

## 🐳 Docker Management Commands

### Basic Operations
```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View container logs
docker logs media-downloader

# Stop container
docker stop media-downloader

# Start container
docker start media-downloader

# Remove container
docker rm media-downloader

# Remove image
docker rmi universal-media-downloader
```

### Advanced Docker Usage
```bash
# Run with environment variables
docker run -d \
  -p 8000:8000 \
  -e HOST=0.0.0.0 \
  -e PORT=8000 \
  universal-media-downloader

# Run with resource limits
docker run -d \
  -p 8000:8000 \
  --memory=1g \
  --cpus=2 \
  universal-media-downloader

# Run with custom download path
docker run -d \
  -p 8000:8000 \
  -v /custom/path/downloads:/app/temp_downloads \
  universal-media-downloader
```

## 📤 Pushing to Docker Hub

### Step 1: Prepare for Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag your image (replace 'yourusername' with your Docker Hub username)
docker tag universal-media-downloader yourusername/universal-media-downloader:3.1.0
docker tag universal-media-downloader yourusername/universal-media-downloader:latest

# Verify tags
docker images
```

### Step 2: Push to Docker Hub
```bash
# Push both versions
docker push yourusername/universal-media-downloader:3.1.0
docker push yourusername/universal-media-downloader:latest
```

### Step 3: Pull and Run from Anywhere
```bash
# Pull the image
docker pull yourusername/universal-media-downloader:latest

# Run it
docker run -d -p 8000:8000 yourusername/universal-media-downloader:latest
```

## 🌐 API Endpoints

### Core Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | API information and status |
| `GET` | `/api/health` | System health check |
| `POST` | `/api/info` | Analyze URL and get media information |
| `POST` | `/api/download` | Download media (returns metadata) |
| `GET` | `/api/download-file` | Direct file download |

### Debug & Management Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/debug/logs` | View application logs |
| `DELETE` | `/api/debug/logs` | Clear logs |
| `GET` | `/api/debug/files` | List downloaded files |
| `POST` | `/api/debug/fix-yt-dlp` | Reinstall yt-dlp |
| `DELETE` | `/api/files/{filename}` | Delete specific file |
| `DELETE` | `/api/files` | Clear all downloaded files |
