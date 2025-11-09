import logging
import json
import socket
import subprocess
import sys
import os
from datetime import datetime
from typing import Dict, List, Optional, Any
from pathlib import Path

class Config:
    """Application configuration"""
    API_TITLE = "Universal Media Downloader API"
    API_VERSION = "3.1.0"
    HOST = "0.0.0.0"
    PORT = 8000
    
    DEFAULT_DOWNLOAD_FOLDER = "temp_downloads"
    PROGRESS_FILE = "download_progress.json"
    LOG_FILE = "debug_logs.json"
    APP_LOG_FILE = "media_downloader.log"
    
    YT_DLP_RETRIES = 10
    YT_DLP_FRAGMENT_RETRIES = 10
    YT_DLP_THROTTLE_RATE = 5000000  
    YT_DLP_SOCKET_TIMEOUT = 30
    
    SUPPORTED_DOMAINS = [
        'youtube.com', 'youtu.be'
    ]
    
    SUSPICIOUS_URL_PATTERNS = [
        r'malware', r'virus', r'phishing', r'scam', r'exploit',
        r'\.exe$', r'\.bat$', r'\.cmd$', r'\.scr$', r'javascript:',
        r'vbscript:', r'data:text/html'
    ]

config = Config()
Path(config.DEFAULT_DOWNLOAD_FOLDER).mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(config.APP_LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)
debug_logs: List[Dict] = []

def save_debug_logs():
    """Save debug logs to file"""
    try:
        with open(config.LOG_FILE, 'w') as f:
            json.dump(debug_logs[-1000:], f, indent=2)
    except Exception as e:
        logger.error(f"Error saving debug logs: {e}")

def add_debug_log(level: str, message: str, details: Dict = None):
    """Add debug log with timestamp"""
    log_entry = {
        'timestamp': datetime.now().isoformat(),
        'level': level,
        'message': message,
        'details': details or {}
    }
    debug_logs.append(log_entry)
    logger.log(getattr(logging, level.upper(), logging.INFO), message)
    save_debug_logs()

def get_local_ip() -> str:
    """Get the local IP address"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            return s.getsockname()[0]
    except:
        return "Unable to determine IP"

def check_ffmpeg() -> bool:
    """Check if FFmpeg is available"""
    try:
        result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            version_line = result.stdout.split('\n')[0] if result.stdout else "Unknown"
            add_debug_log('info', f"✅ FFmpeg available: {version_line}")
            return True
        return False
    except FileNotFoundError:
        add_debug_log('warning', "⚠️ FFmpeg not found in PATH")
        return False
    except Exception as e:
        add_debug_log('error', f"❌ FFmpeg check failed: {e}")
        return False

class YtDlpManager:
    """Manages yt-dlp installation and configuration"""
    
    def __init__(self):
        self.youtube_dlp = None
        self.ffmpeg_available = False
    
    def initialize(self) -> bool:
        """Initialize yt-dlp"""
        try:
            import yt_dlp as youtube_dlp
            self.youtube_dlp = youtube_dlp
            add_debug_log('info', "✅ yt-dlp imported successfully")
            
            # Test yt-dlp
            try:
                test_result = subprocess.run(
                    [sys.executable, "-m", "yt_dlp", "--version"],
                    capture_output=True, text=True, timeout=10
                )
                if test_result.returncode == 0:
                    version = test_result.stdout.strip()
                    add_debug_log('info', f"🎯 yt-dlp version: {version}")
            except Exception as test_error:
                add_debug_log('warning', f"⚠️ yt-dlp test failed: {test_error}")
            
            self.ffmpeg_available = check_ffmpeg()
            return True
        except ImportError as e:
            add_debug_log('error', f"❌ yt-dlp import failed: {e}")
            return False
    
    def clean_install(self) -> bool:
        """Reinstall yt-dlp"""
        try:
            add_debug_log('info', "🧹 Performing clean yt-dlp installation...")
            
            # Uninstall
            subprocess.run([sys.executable, "-m", "pip", "uninstall", "-y", "yt-dlp"],
                         capture_output=True, timeout=60)
            
            # Clear cache
            subprocess.run([sys.executable, "-m", "pip", "cache", "purge"],
                         capture_output=True, timeout=30)
            
            # Install
            result = subprocess.run(
                [sys.executable, "-m", "pip", "install", "--no-cache-dir",
                 "yt-dlp[default]", "--upgrade", "--force-reinstall"],
                capture_output=True, text=True, timeout=300
            )
            
            if result.returncode == 0:
                add_debug_log('info', "✅ yt-dlp clean installation successful!")
                return True
            else:
                add_debug_log('error', f"❌ Installation failed: {result.stderr}")
                return False
        except Exception as e:
            add_debug_log('error', f"💥 Clean installation failed: {e}")
            return False
    
    def get_ydl_opts(self, format_type: str, download_path: str) -> Dict:
        """Get yt-dlp options"""
        base_opts = {
            'ignoreerrors': True,
            'no_warnings': False,
            'quiet': False,
            'verbose': True,
            'retries': config.YT_DLP_RETRIES,
            'fragment_retries': config.YT_DLP_FRAGMENT_RETRIES,
            'skip_unavailable_fragments': True,
            'file_access_retries': 3,
            'throttledratelimit': config.YT_DLP_THROTTLE_RATE,
            'sleep_interval': 1,
            'max_sleep_interval': 5,
            'outtmpl': f'{download_path}/%(title).150s.%(ext)s',
            'restrictfilenames': True,
            'windowsfilenames': True,
            'socket_timeout': config.YT_DLP_SOCKET_TIMEOUT,
            'source_address': '0.0.0.0',
            'extract_flat': False,
            'force_json': True,
            'extractor_args': {
                'youtube': {
                    'player_client': ['android', 'web'],
                    'player_skip': ['configs', 'webpage'],
                },
                'spotify': {'format': 'bestaudio'}
            }
        }
        
        if format_type == "audio":
            if self.ffmpeg_available:
                base_opts.update({
                    'format': 'bestaudio/best',
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': 'mp3',
                        'preferredquality': '192',
                    }],
                })
            else:
                base_opts['format'] = 'bestaudio[ext=m4a]/bestaudio/best'
        else:
            if self.ffmpeg_available:
                base_opts.update({
                    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
                    'merge_output_format': 'mp4',
                })
            else:
                base_opts['format'] = 'best[ext=mp4]/best[height<=1080]/best'
        
        return base_opts

yt_dlp_manager = YtDlpManager()