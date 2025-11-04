from fastapi import FastAPI, HTTPException, Form, BackgroundTasks, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse, JSONResponse
import os
import socket
import uvicorn
import logging
import subprocess
import sys
import asyncio
from typing import Dict, List, Optional, Any
import json
from pathlib import Path
import aiofiles
import time
from datetime import datetime
import shutil
import re
import urllib.parse
from urllib.parse import urlparse
import mimetypes

# Enhanced logging with file output
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('media_downloader.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Universal Media Downloader API",
    description="Advanced media downloader supporting YouTube, Spotify, and 1000+ sites with custom download paths",
    version="3.1.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enhanced configuration
DEFAULT_DOWNLOAD_FOLDER = "temp_downloads"
PROGRESS_FILE = "download_progress.json"
LOG_FILE = "debug_logs.json"
SUPPORTED_DOMAINS = [
    'youtube.com', 'youtu.be', 'spotify.com', 'soundcloud.com', 
    'vimeo.com', 'dailymotion.com', 'twitter.com', 'x.com',
    'instagram.com', 'facebook.com', 'tiktok.com', 'twitch.tv',
    'bandcamp.com', 'mixcloud.com', 'audiomack.com'
]
os.makedirs(DEFAULT_DOWNLOAD_FOLDER, exist_ok=True)

# Store download progress and debug logs
download_progress: Dict[str, Dict] = {}
debug_logs: List[Dict] = []

def save_progress():
    """Save progress to file"""
    try:
        with open(PROGRESS_FILE, 'w') as f:
            json.dump(download_progress, f)
    except Exception as e:
        logger.error(f"Error saving progress: {e}")

def load_progress():
    """Load progress from file"""
    global download_progress
    try:
        if os.path.exists(PROGRESS_FILE):
            with open(PROGRESS_FILE, 'r') as f:
                download_progress = json.load(f)
    except Exception as e:
        logger.error(f"Error loading progress: {e}")

def save_debug_logs():
    """Save debug logs to file"""
    try:
        with open(LOG_FILE, 'w') as f:
            json.dump(debug_logs[-1000:], f, indent=2)  # Keep last 1000 logs
    except Exception as e:
        logger.error(f"Error saving debug logs: {e}")

def add_debug_log(level: str, message: str, details: Dict = None):
    """Add debug log with timestamp and details"""
    log_entry = {
        'timestamp': datetime.now().isoformat(),
        'level': level,
        'message': message,
        'details': details or {}
    }
    debug_logs.append(log_entry)
    logger.log(getattr(logging, level.upper(), logging.INFO), message)
    save_debug_logs()

class DownloadProgressHook:
    def __init__(self, download_id: str, download_path: str):
        self.download_id = download_id
        self.download_path = download_path
        
    def hook(self, d):
        if d['status'] == 'downloading':
            download_progress[self.download_id] = {
                'status': 'downloading',
                'percent': d.get('_percent_str', '0%').strip(),
                'speed': d.get('_speed_str', 'N/A'),
                'eta': d.get('_eta_str', 'N/A'),
                'filename': d.get('filename', ''),
                'download_path': self.download_path,
                'timestamp': str(time.time())
            }
            save_progress()
        elif d['status'] == 'finished':
            download_progress[self.download_id] = {
                'status': 'finished',
                'filename': d.get('filename', ''),
                'download_path': self.download_path,
                'timestamp': str(time.time())
            }
            save_progress()

def clean_install_yt_dlp():
    """Completely clean and reinstall yt-dlp with enhanced error handling"""
    try:
        add_debug_log('info', "🧹 Performing clean yt-dlp installation...")
        
        # Get current yt-dlp version
        try:
            result = subprocess.run([
                sys.executable, "-m", "yt_dlp", "--version"
            ], capture_output=True, text=True, timeout=10)
            current_version = result.stdout.strip() if result.returncode == 0 else "Unknown"
            add_debug_log('info', f"📦 Current yt-dlp version: {current_version}")
        except:
            current_version = "Not installed"
        
        # Uninstall existing yt-dlp
        add_debug_log('info', "🗑️ Uninstalling existing yt-dlp...")
        uninstall_result = subprocess.run([
            sys.executable, "-m", "pip", "uninstall", "-y", "yt-dlp"
        ], capture_output=True, text=True, timeout=60)
        
        if uninstall_result.returncode != 0:
            add_debug_log('warning', "⚠️ Partial uninstall - continuing...")
        
        # Clear pip cache
        add_debug_log('info', "🧹 Clearing pip cache...")
        subprocess.run([
            sys.executable, "-m", "pip", "cache", "purge"
        ], capture_output=True, timeout=30)
        
        # Install latest yt-dlp with specific version that works better
        add_debug_log('info', "📥 Installing latest yt-dlp...")
        result = subprocess.run([
            sys.executable, "-m", "pip", "install", "--no-cache-dir", 
            "yt-dlp[default]", "--upgrade", "--force-reinstall"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            # Verify installation
            verify_result = subprocess.run([
                sys.executable, "-m", "yt_dlp", "--version"
            ], capture_output=True, text=True, timeout=10)
            
            new_version = verify_result.stdout.strip() if verify_result.returncode == 0 else "Unknown"
            
            add_debug_log('info', f"✅ yt-dlp clean installation successful! Version: {new_version}")
            add_debug_log('info', f"🔄 Version changed: {current_version} -> {new_version}")
            return True
        else:
            add_debug_log('error', f"❌ yt-dlp installation failed: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        add_debug_log('error', "💥 Installation timeout - process took too long")
        return False
    except Exception as e:
        add_debug_log('error', f"💥 Clean installation failed: {e}")
        return False

def get_local_ip():
    """Get the local IP address of the computer"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            return s.getsockname()[0]
    except:
        return "Unable to determine IP"

def check_ffmpeg():
    """Check if FFmpeg is available with detailed info"""
    try:
        result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            # Extract version info
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

def initialize_yt_dlp():
    """Initialize yt-dlp with comprehensive error handling"""
    global youtube_dlp
    try:
        import yt_dlp as youtube_dlp
        add_debug_log('info', "✅ yt-dlp imported successfully")
        
        # Test yt-dlp functionality
        try:
            test_result = subprocess.run([
                sys.executable, "-m", "yt_dlp", "--version"
            ], capture_output=True, text=True, timeout=10)
            
            if test_result.returncode == 0:
                version = test_result.stdout.strip()
                add_debug_log('info', f"🎯 yt-dlp version: {version}")
            else:
                add_debug_log('warning', f"⚠️ yt-dlp version check failed: {test_result.stderr}")
                
        except Exception as test_error:
            add_debug_log('warning', f"⚠️ yt-dlp test failed: {test_error}")
        
        # Check FFmpeg
        ffmpeg_available = check_ffmpeg()
        if ffmpeg_available:
            add_debug_log('info', "✅ FFmpeg is available - full functionality enabled")
        else:
            add_debug_log('warning', "⚠️ FFmpeg not found - some features limited")
            
        return True
    except ImportError as e:
        add_debug_log('error', f"❌ yt-dlp import failed: {e}")
        return False
    except Exception as e:
        add_debug_log('error', f"❌ yt-dlp initialization error: {e}")
        return False

def validate_url(url: str) -> Dict[str, Any]:
    """Comprehensive URL validation and analysis"""
    try:
        add_debug_log('debug', f"🔍 Validating URL: {url}")
        
        # Basic URL parsing
        parsed = urlparse(url)
        if not parsed.scheme or not parsed.netloc:
            return {'valid': False, 'error': 'Invalid URL format'}
        
        domain = parsed.netloc.lower()
        if 'youtube.com' in domain or 'youtu.be' in domain:
            platform = 'youtube'
        elif 'spotify.com' in domain:
            platform = 'spotify'
        elif 'soundcloud.com' in domain:
            platform = 'soundcloud'
        elif any(supported in domain for supported in SUPPORTED_DOMAINS):
            platform = 'supported'
        else:
            platform = 'unknown'
        
        # Check for suspicious patterns
        suspicious_patterns = [
            r'malware', r'virus', r'phishing', r'scam', r'exploit',
            r'\.exe$', r'\.bat$', r'\.cmd$', r'\.scr$', r'javascript:',
            r'vbscript:', r'data:text/html'
        ]
        
        for pattern in suspicious_patterns:
            if re.search(pattern, url, re.IGNORECASE):
                return {
                    'valid': False, 
                    'error': 'Suspicious URL detected - potential security risk',
                    'platform': platform
                }
        
        return {
            'valid': True,
            'platform': platform,
            'domain': domain,
            'sanitized_url': url
        }
        
    except Exception as e:
        add_debug_log('error', f"URL validation error: {e}")
        return {'valid': False, 'error': f'URL validation failed: {str(e)}'}

def validate_download_path(download_path: str) -> Dict[str, Any]:
    if not download_path:
        # Fallback to default folder for laptop/server
        download_path = DEFAULT_DOWNLOAD_FOLDER
    
    try:
        # ✅ Only check .startswith if it is not None
        if isinstance(download_path, str) and download_path.startswith('/storage/'):
            # Android-like path (but backend is on PC)
            add_debug_log('info', f"📁 Android-like path received but backend on Windows: {download_path}")
            # Don’t use it, fallback to local folder instead
            download_path = DEFAULT_DOWNLOAD_FOLDER

        # Create folder if not exists
        if not os.path.exists(download_path):
            os.makedirs(download_path, exist_ok=True)

        # Check write permissions
        test_file = os.path.join(download_path, '.write_test')
        with open(test_file, 'w') as f:
            f.write('test')
        os.remove(test_file)

        return {
            'valid': True,
            'download_path': download_path,
            'absolute_path': os.path.abspath(download_path)
        }

    except Exception as e:
        return {
            'valid': False,
            'error': f'Invalid path: {str(e)}'
        }


    """Validate and prepare download path"""
    try:
        add_debug_log('debug', f"🔍 Validating download path: {download_path}")
        
        # If no custom path provided, use default
        if not download_path or download_path == 'default':
            download_path = DEFAULT_DOWNLOAD_FOLDER
            add_debug_log('info', f"📁 Using default download path: {download_path}")
        
        # Ensure path exists
        if not os.path.exists(download_path):
            add_debug_log('info', f"📁 Creating download directory: {download_path}")
            os.makedirs(download_path, exist_ok=True)
        
        # Check write permissions
        test_file = os.path.join(download_path, '.write_test')
        try:
            with open(test_file, 'w') as f:
                f.write('test')
            os.remove(test_file)
            add_debug_log('info', f"✅ Write access verified for: {download_path}")
        except Exception as e:
            add_debug_log('error', f"❌ No write access to: {download_path} - {e}")
            return {
                'valid': False,
                'error': f'No write permission for directory: {download_path}'
            }
        
        return {
            'valid': True,
            'download_path': download_path,
            'absolute_path': os.path.abspath(download_path)
        }
        
    except Exception as e:
        add_debug_log('error', f"💥 Path validation failed: {e}")
        return {
            'valid': False,
            'error': f'Invalid download path: {str(e)}'
        }

def _find_best_downloaded_file(downloaded_filename: str, original_title: str, format_type: str, ffmpeg_available: bool, download_path: str) -> str:
    """Find the best downloaded file and clean up temporary files"""
    add_debug_log('debug', f"🔍 Finding best file for: {downloaded_filename} in {download_path}")
    
    base_name = os.path.splitext(os.path.basename(downloaded_filename))[0]
    base_name = base_name.split('.f')[0]  # Remove format suffixes like .f140
    
    # Look for all files that match our download in the specified path
    matching_files = []
    for file in os.listdir(download_path):
        if file.startswith(base_name) and os.path.isfile(os.path.join(download_path, file)):
            file_path = os.path.join(download_path, file)
            file_size = os.path.getsize(file_path)
            matching_files.append((file_path, file_size, file))
    
    add_debug_log('debug', f"📁 Found {len(matching_files)} matching files in {download_path}")
    
    if not matching_files:
        add_debug_log('warning', "❌ No matching files found, using original")
        return downloaded_filename
    
    # Select the best file
    if len(matching_files) == 1:
        best_file = matching_files[0][0]
        add_debug_log('debug', f"✅ Single file found: {os.path.basename(best_file)}")
    else:
        # Prefer files without format codes (like .f140) as they're usually the final output
        clean_files = [f for f in matching_files if '.f' not in f[2]]
        if clean_files:
            # Take the largest clean file
            clean_files.sort(key=lambda x: x[1], reverse=True)
            best_file = clean_files[0][0]
            add_debug_log('debug', f"✅ Selected largest clean file: {os.path.basename(best_file)}")
        else:
            # Take the largest file overall
            matching_files.sort(key=lambda x: x[1], reverse=True)
            best_file = matching_files[0][0]
            add_debug_log('debug', f"✅ Selected largest file: {os.path.basename(best_file)}")
    
    # Clean up temporary format files (like .f140.m4a, .f401.mp4)
    temp_files_cleaned = 0
    for file_path, _, file_name in matching_files:
        if file_path != best_file and '.f' in file_name:
            try:
                os.remove(file_path)
                temp_files_cleaned += 1
                add_debug_log('debug', f"🧹 Cleaned up temporary file: {file_name}")
            except Exception as e:
                add_debug_log('warning', f"Could not clean up {file_name}: {e}")
    
    if temp_files_cleaned > 0:
        add_debug_log('info', f"🗑️ Cleaned {temp_files_cleaned} temporary files")
    
    # Ensure proper file extension
    final_filename = best_file
    if format_type == "audio":
        if not final_filename.lower().endswith(('.mp3', '.m4a', '.aac', '.opus', '.wav', '.flac')):
            if ffmpeg_available:
                new_filename = os.path.splitext(final_filename)[0] + '.mp3'
            else:
                new_filename = os.path.splitext(final_filename)[0] + '.m4a'
            
            if new_filename != final_filename and not os.path.exists(new_filename):
                try:
                    shutil.move(final_filename, new_filename)
                    final_filename = new_filename
                    add_debug_log('info', f"📁 Renamed to: {os.path.basename(final_filename)}")
                except Exception as e:
                    add_debug_log('warning', f"Could not rename file: {e}")
    else:
        video_extensions = ('.mp4', '.mkv', '.webm', '.avi', '.mov', '.wmv', '.flv')
        if not final_filename.lower().endswith(video_extensions):
            new_filename = os.path.splitext(final_filename)[0] + '.mp4'
            if new_filename != final_filename and not os.path.exists(new_filename):
                try:
                    shutil.move(final_filename, new_filename)
                    final_filename = new_filename
                    add_debug_log('info', f"📁 Renamed to: {os.path.basename(final_filename)}")
                except Exception as e:
                    add_debug_log('warning', f"Could not rename file: {e}")
    
    add_debug_log('info', f"✅ Final file: {os.path.basename(final_filename)} in {download_path}")
    return final_filename

def get_enhanced_ydl_opts(format_type: str, ffmpeg_available: bool, download_path: str) -> Dict:
    """Get enhanced yt-dlp options for better compatibility with custom download path"""
    
    base_opts = {
        # Enhanced error handling
        'ignoreerrors': True,
        'no_warnings': False,
        'quiet': False,
        'verbose': True,
        
        # Retry settings
        'retries': 10,
        'fragment_retries': 10,
        'skip_unavailable_fragments': True,
        'file_access_retries': 3,
        
        # Rate limiting
        'throttledratelimit': 5000000,  # 5 MB/s
        'sleep_interval': 1,
        'max_sleep_interval': 5,
        
        # Output settings - USE CUSTOM DOWNLOAD PATH
        'outtmpl': os.path.join(download_path, '%(title).150s.%(ext)s'),
        'restrictfilenames': True,
        'windowsfilenames': os.name == 'nt',
        
        # Network settings
        'socket_timeout': 30,
        'source_address': '0.0.0.0',
        
        # Extractor settings
        'extract_flat': False,
        'force_json': True,
    }
    
    # Platform-specific extractor args
    base_opts['extractor_args'] = {
        'youtube': {
            'player_client': ['android', 'web'],
            'player_skip': ['configs', 'webpage'],
        },
        'spotify': {
            'format': 'bestaudio',
        }
    }
    
    # Format-specific options
    if format_type == "audio":
        if ffmpeg_available:
            base_opts.update({
                'format': 'bestaudio/best',
                'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': 'mp3',
                    'preferredquality': '192',
                }],
            })
        else:
            base_opts.update({
                'format': 'bestaudio[ext=m4a]/bestaudio/best',
            })
    else:
        if ffmpeg_available:
            base_opts.update({
                'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
                'merge_output_format': 'mp4',
            })
        else:
            base_opts.update({
                'format': 'best[ext=mp4]/best[height<=1080]/best',
            })
    
    return base_opts

def download_media(url: str, format_type: str = "best", download_path: str = None) -> Dict[str, Any]:
    """Enhanced media download with comprehensive error handling and custom download paths"""
    if 'youtube_dlp' not in globals():
        raise HTTPException(status_code=500, detail="yt-dlp not initialized")
        
    add_debug_log('info', f"🚀 Starting download - URL: {url}, Format: {format_type}, Path: {download_path}")
    
    # Validate URL first
    url_validation = validate_url(url)
    if not url_validation['valid']:
        add_debug_log('error', f"❌ URL validation failed: {url_validation['error']}")
        return {
            'title': 'Invalid URL',
            'success': False,
            'error': url_validation['error'],
            'url': url,
            'platform': url_validation.get('platform', 'unknown')
        }
    
    # Validate download path
    path_validation = validate_download_path(download_path)
    if not path_validation['valid']:
        add_debug_log('error', f"❌ Download path validation failed: {path_validation['error']}")
        return {
            'title': 'Path Error',
            'success': False,
            'error': path_validation['error'],
            'url': url,
            'platform': url_validation.get('platform', 'unknown')
        }
    
    actual_download_path = path_validation['download_path']
    platform = url_validation['platform']
    add_debug_log('info', f"🌐 Platform detected: {platform}")
    add_debug_log('info', f"📁 Downloading to: {actual_download_path}")
    
    # SMART format selection based on FFmpeg availability
    ffmpeg_available = check_ffmpeg()
    ydl_opts = get_enhanced_ydl_opts(format_type, ffmpeg_available, actual_download_path)

    try:
        with youtube_dlp.YoutubeDL(ydl_opts) as ydl:
            # Get info first with enhanced error handling
            add_debug_log('debug', "🔍 Getting video information...")
            try:
                info = ydl.extract_info(url, download=False, process=False)
                if not info:
                    add_debug_log('error', "❌ Could not extract video information")
                    return {
                        'title': 'Unknown',
                        'success': False,
                        'error': 'Video not available or restricted',
                        'url': url,
                        'platform': platform,
                        'download_path': actual_download_path
                    }
            except Exception as info_error:
                add_debug_log('error', f"❌ Info extraction failed: {info_error}")
                
                # Try alternative info extraction
                try:
                    add_debug_log('debug', "🔄 Trying alternative info extraction...")
                    info = ydl.extract_info(url, download=False)
                    if not info:
                        raise info_error
                except:
                    return {
                        'title': 'Unknown',
                        'success': False,
                        'error': f'Cannot access video information: {str(info_error)}',
                        'url': url,
                        'platform': platform,
                        'download_path': actual_download_path
                    }
            
            original_title = info.get('title', 'Unknown')
            duration = info.get('duration', 0)
            uploader = info.get('uploader', 'Unknown')
            
            add_debug_log('info', f"✅ Video available: '{original_title}' by {uploader} ({duration}s)")
            add_debug_log('debug', f"📊 Video details: {json.dumps({k: v for k, v in info.items() if k in ['id', 'view_count', 'like_count', 'categories']}, default=str)}")
            
            # Check for potential issues
            if info.get('age_limit', 0) > 0:
                add_debug_log('warning', "⚠️ Video may be age-restricted")
            if info.get('is_live'):
                add_debug_log('warning', "⚠️ This is a live stream - download may not work")
            
            # Perform download with comprehensive error handling
            add_debug_log('info', "⬇️ Starting download process...")
            try:
                info = ydl.extract_info(url, download=True)
                downloaded_filename = ydl.prepare_filename(info)
                add_debug_log('debug', f"📥 Download completed, filename: {downloaded_filename}")
            except Exception as download_error:
                error_msg = str(download_error)
                add_debug_log('error', f"❌ Download failed: {error_msg}")
                
                # Enhanced error handling for common issues
                if any(code in error_msg for code in ['403', 'Forbidden']):
                    add_debug_log('warning', "🔄 Trying alternative download method for 403 error...")
                    try:
                        alt_ydl_opts = ydl_opts.copy()
                        alt_ydl_opts.update({
                            'format': 'worst[ext=mp4]/worst',
                            'sleep_interval': 3,
                            'retries': 5
                        })
                        with youtube_dlp.YoutubeDL(alt_ydl_opts) as alt_ydl:
                            info = alt_ydl.extract_info(url, download=True)
                            downloaded_filename = alt_ydl.prepare_filename(info)
                        add_debug_log('info', "✅ Alternative download successful!")
                    except Exception as alt_error:
                        add_debug_log('error', f"❌ Alternative download failed: {alt_error}")
                        raise download_error
                else:
                    raise download_error
            
            # SMART file detection and cleanup with custom path
            final_filename = _find_best_downloaded_file(downloaded_filename, original_title, format_type, ffmpeg_available, actual_download_path)
            
            if not os.path.exists(final_filename):
                add_debug_log('error', f"❌ Downloaded file not found: {final_filename}")
                return {
                    'title': original_title,
                    'success': False,
                    'error': 'Downloaded file not found after processing',
                    'url': url,
                    'platform': platform,
                    'download_path': actual_download_path
                }
            
            file_size = os.path.getsize(final_filename)
            add_debug_log('info', f"✅ Download completed successfully: {final_filename} ({file_size} bytes)")
            
            return {
                'filename': os.path.basename(final_filename),
                'filepath': final_filename,
                'title': original_title,
                'duration': duration,
                'file_size': file_size,
                'success': True,
                'url': url,
                'format': format_type,
                'has_ffmpeg': ffmpeg_available,
                'platform': platform,
                'uploader': uploader,
                'download_path': actual_download_path
            }
            
    except Exception as e:
        error_msg = str(e)
        add_debug_log('error', f"❌ Download process failed: {error_msg}")
        
        # Comprehensive error messages
        error_mapping = {
            '403': "YouTube blocked the download (403 Forbidden). Try again later or use a different video.",
            'Forbidden': "Access forbidden. The video may be restricted in your region.",
            'Private video': "This video is private and cannot be downloaded",
            'Members-only': "This is a members-only video",
            'Sign in': "This video requires sign-in to access",
            'Video unavailable': "Video is not available in your country or has been removed",
            'Unsupported URL': "This URL is not supported",
            'FFmpeg': "FFmpeg not available. Install FFmpeg for better format support.",
            'age restricted': "This video is age-restricted and cannot be downloaded",
            'live stream': "Live streams cannot be downloaded",
        }
        
        user_error = "Download failed due to an unknown error"
        for key, message in error_mapping.items():
            if key.lower() in error_msg.lower():
                user_error = message
                break
        else:
            # Extract the main error message
            user_error = error_msg.split('ERROR:')[-1].strip() if 'ERROR:' in error_msg else error_msg
            user_error = user_error.split('\n')[0]  # Take only first line
            
        return {
            'title': 'Unknown',
            'success': False,
            'error': user_error,
            'url': url,
            'platform': platform,
            'download_path': actual_download_path,
            'debug_info': error_msg[:500]  # Include limited debug info
        }

# Initialize on startup
load_progress()
add_debug_log('info', "🚀 Universal Media Downloader API Starting...")
add_debug_log('info', f"📁 Default download folder: {os.path.abspath(DEFAULT_DOWNLOAD_FOLDER)}")
add_debug_log('info', f"🌐 Supported domains: {', '.join(SUPPORTED_DOMAINS[:5])}...")

if not initialize_yt_dlp():
    add_debug_log('warning', "🔄 yt-dlp initialization failed, attempting clean installation...")
    if clean_install_yt_dlp():
        initialize_yt_dlp()

# API Routes
@app.get("/")
async def root():
    local_ip = get_local_ip()
    yt_dlp_status = "✅ Working" if 'youtube_dlp' in globals() else "❌ Broken"
    ffmpeg_status = "✅ Available" if check_ffmpeg() else "❌ Not Found"
    
    return {
        "message": "Universal Media Downloader API",
        "status": "healthy", 
        "version": "3.1.0",
        "local_ip": local_ip,
        "yt_dlp_status": yt_dlp_status,
        "ffmpeg_status": ffmpeg_status,
        "default_download_folder": DEFAULT_DOWNLOAD_FOLDER,
        "supported_platforms": SUPPORTED_DOMAINS,
        "features": [
            "YouTube, Spotify, SoundCloud support",
            "1000+ websites via yt-dlp",
            "MP4 Video & MP3 Audio downloads",
            "Custom download path support",
            "Playlist analysis and download",
            "Advanced error handling",
            "Security validation",
            "Progress tracking",
            "Comprehensive logging"
        ],
        "endpoints": [
            "GET /api/health - System status",
            "POST /api/info - Analyze URL",
            "GET /api/download-file - Download file",
            "GET /api/debug/logs - View debug logs",
            "GET /api/debug/files - List downloaded files"
        ],
        "access_urls": [
            f"http://localhost:8000",
            f"http://127.0.0.1:8000", 
            f"http://{local_ip}:8000"
        ]
    }

@app.get("/api/health")
async def health_check():
    yt_dlp_status = "✅ Working" if 'youtube_dlp' in globals() else "❌ Broken"
    ffmpeg_status = "✅ Available" if check_ffmpeg() else "❌ Not Found"
    
    # Check disk space
    try:
        disk_usage = shutil.disk_usage(DEFAULT_DOWNLOAD_FOLDER)
        free_space_gb = disk_usage.free / (1024**3)
        disk_status = "✅ Sufficient" if free_space_gb > 1 else "⚠️ Low"
    except:
        free_space_gb = 0
        disk_status = "❌ Unknown"
    
    return {
        "status": "OK", 
        "service": "universal-media-downloader",
        "yt_dlp_status": yt_dlp_status,
        "ffmpeg_status": ffmpeg_status,
        "disk_status": disk_status,
        "free_space_gb": round(free_space_gb, 2),
        "version": "3.1.0",
        "timestamp": datetime.now().isoformat(),
        "default_download_folder": os.path.abspath(DEFAULT_DOWNLOAD_FOLDER),
        "download_folder_exists": os.path.exists(DEFAULT_DOWNLOAD_FOLDER),
        "supported_platforms_count": len(SUPPORTED_DOMAINS)
    }

@app.get("/api/progress/{download_id}")
async def get_progress(download_id: str):
    """Get download progress"""
    return download_progress.get(download_id, {"status": "unknown"})

def get_playlist_info(url: str):
    """Enhanced playlist information with comprehensive error handling"""
    if 'youtube_dlp' not in globals():
        raise HTTPException(status_code=500, detail="yt-dlp not initialized")
        
    add_debug_log('info', f"🔍 Analyzing URL: {url}")
    
    # Validate URL first
    url_validation = validate_url(url)
    if not url_validation['valid']:
        raise HTTPException(status_code=400, detail=url_validation['error'])
    
    ydl_opts = {
        'quiet': True,
        'extract_flat': True,
        'no_warnings': False,
        'ignoreerrors': True,
        'extract_flat': 'in_playlist',
    }
    
    try:
        with youtube_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            if not info:
                raise HTTPException(status_code=400, detail="Could not extract information from URL")
                
            add_debug_log('info', f"✅ Successfully analyzed: {info.get('title', 'Unknown')}")
            
            if 'entries' in info:
                videos = []
                available_count = 0
                unavailable_count = 0
                
                for entry in info['entries']:
                    if entry and entry.get('title'):
                        videos.append({
                            'title': entry.get('title', 'Unknown'),
                            'url': entry.get('url', ''),
                            'webpage_url': entry.get('webpage_url', ''),
                            'id': entry.get('id', ''),
                            'duration': entry.get('duration', 0),
                            'thumbnail': entry.get('thumbnail', ''),
                            'uploader': entry.get('uploader', 'Unknown'),
                            'available': True,
                        })
                        available_count += 1
                    else:
                        videos.append({
                            'title': 'Unavailable Video',
                            'url': '',
                            'webpage_url': '',
                            'id': '',
                            'duration': 0,
                            'thumbnail': '',
                            'uploader': 'Unknown',
                            'available': False,
                        })
                        unavailable_count += 1
                
                add_debug_log('info', f"📊 Playlist analysis: {available_count} available, {unavailable_count} unavailable")
                
                return {
                    'title': info.get('title', 'Unknown Playlist'),
                    'uploader': info.get('uploader', 'Unknown'),
                    'video_count': len(videos),
                    'available_videos': available_count,
                    'unavailable_videos': unavailable_count,
                    'videos': videos,
                    'type': 'playlist',
                    'platform': url_validation['platform']
                }
            else:
                # Single video
                return {
                    'title': info.get('title', 'Unknown'),
                    'uploader': info.get('uploader', 'Unknown'),
                    'video_count': 1,
                    'available_videos': 1,
                    'unavailable_videos': 0,
                    'videos': [{
                        'title': info.get('title', 'Unknown'),
                        'url': url,
                        'webpage_url': info.get('webpage_url', url),
                        'id': info.get('id', ''),
                        'duration': info.get('duration', 0),
                        'thumbnail': info.get('thumbnail', ''),
                        'uploader': info.get('uploader', 'Unknown'),
                        'available': True,
                    }],
                    'type': 'single',
                    'platform': url_validation['platform']
                }
    except Exception as e:
        add_debug_log('error', f"❌ Analysis failed: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Error getting info: {str(e)}")

@app.post("/api/info")
async def get_info(url: str = Form(...)):
    """Get information about a URL (video or playlist) with enhanced validation"""
    add_debug_log('info', f"📊 Info request for: {url}")
    
    # Validate URL
    url_validation = validate_url(url)
    if not url_validation['valid']:
        add_debug_log('error', f"❌ Invalid URL: {url_validation['error']}")
        raise HTTPException(status_code=400, detail=url_validation['error'])
    
    try:
        info = get_playlist_info(url)
        add_debug_log('info', f"✅ Info retrieval successful: {info['title']}")
        return info
    except HTTPException:
        raise
    except Exception as e:
        add_debug_log('error', f"💥 Info endpoint error: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Analysis failed: {str(e)}")

@app.post("/api/download")
async def download_url(url: str = Form(...), format_type: str = Form("best"), download_path: str = Form(None)):
    """Download a URL (video or audio) with custom download path"""
    add_debug_log('info', f"⬇️ Download request - URL: {url}, Format: {format_type}, Path: {download_path}")
    try:
        result = download_media(url, format_type, download_path)
        return result
    except Exception as e:
        add_debug_log('error', f"💥 Download endpoint error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/download-file")
async def download_file(url: str, format_type: str = "best", download_path: str = None):
    """Download file for direct mobile download with custom download path support"""
    add_debug_log('info', f"📥 Download file request - URL: {url}, Format: {format_type}, Path: {download_path}")
    
    try:
        # Handle playlist URLs by using the first available video
        try:
            playlist_info = get_playlist_info(url)
            if playlist_info['type'] == 'playlist':
                available_videos = [v for v in playlist_info['videos'] if v['available'] and (v.get('url') or v.get('webpage_url'))]
                if available_videos:
                    first_video = available_videos[0]
                    video_url = first_video.get('url') or first_video.get('webpage_url')
                    if video_url:
                        url = video_url
                        add_debug_log('info', f"🎵 Using first video from playlist: {first_video.get('title')}")
        except Exception as e:
            add_debug_log('warning', f"⚠️ Playlist detection failed: {e}")

        # Download the media with custom path
        add_debug_log('info', f"⬇️ Starting download: {url} to {download_path}")
        result = download_media(url, format_type, download_path)
        
        if result['success'] and os.path.exists(result['filepath']):
            add_debug_log('info', f"✅ Download successful: {result['filename']} in {result['download_path']}")
            
            # Determine content type
            if format_type == "audio":
                media_type = 'audio/mpeg' if result['filename'].endswith('.mp3') else 'audio/mp4'
            else:
                media_type = 'video/mp4'
            
            return FileResponse(
                result['filepath'],
                filename=result['filename'],
                media_type=media_type,
                headers={
                    'Content-Disposition': f'attachment; filename="{result["filename"]}"',
                    'X-File-Size': str(result['file_size']),
                    'X-Duration': str(result['duration']),
                    'X-Platform': result.get('platform', 'unknown'),
                    'X-Download-Path': result.get('download_path', 'unknown')
                }
            )
        else:
            error_msg = result.get('error', 'Download failed')
            add_debug_log('error', f"❌ Download failed: {error_msg}")
            raise HTTPException(status_code=400, detail=error_msg)
            
    except HTTPException:
        raise
    except Exception as e:
        add_debug_log('error', f"💥 Download file error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Download error: {str(e)}")

@app.get("/api/debug/logs")
async def get_debug_logs(limit: int = 100, level: str = None):
    """Get debug logs with filtering"""
    filtered_logs = debug_logs
    if level:
        filtered_logs = [log for log in debug_logs if log['level'] == level.lower()]
    
    return {
        'total_logs': len(debug_logs),
        'filtered_logs': len(filtered_logs),
        'logs': filtered_logs[-limit:]
    }

@app.delete("/api/debug/logs")
async def clear_debug_logs():
    """Clear debug logs"""
    global debug_logs
    debug_logs.clear()
    add_debug_log('info', "🗑️ Debug logs cleared")
    return {"message": "Debug logs cleared successfully"}

@app.get("/api/test-download")
async def test_download(url: str = "https://www.youtube.com/watch?v=dQw4w9WgXcQ", format_type: str = "best", download_path: str = None):
    """Test endpoint for downloads with custom path"""
    add_debug_log('info', f"🧪 Test download: {url}, format: {format_type}, path: {download_path}")
    
    result = download_media(url, format_type, download_path)
    files_info = await debug_files()
    system_status = await health_check()
    
    return {
        "test_url": url,
        "format_requested": format_type,
        "download_path": download_path,
        "download_result": result,
        "available_files": files_info,
        "system_status": system_status
    }

@app.get("/api/debug/files")
async def debug_files(download_path: str = None):
    """Debug endpoint to check downloaded files in specified path"""
    files = []
    total_size = 0
    
    try:
        # Use specified path or default
        target_path = download_path if download_path and os.path.exists(download_path) else DEFAULT_DOWNLOAD_FOLDER
        
        if not os.path.exists(target_path):
            return {
                'error': 'Download folder does not exist',
                'download_folder': target_path
            }
            
        for filename in os.listdir(target_path):
            filepath = os.path.join(target_path, filename)
            if os.path.isfile(filepath):
                stat = os.stat(filepath)
                file_info = {
                    'name': filename,
                    'size': stat.st_size,
                    'path': filepath,
                    'modified': stat.st_mtime,
                    'modified_readable': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S'),
                    'extension': os.path.splitext(filename)[1].lower()
                }
                files.append(file_info)
                total_size += stat.st_size
        
        return {
            'download_folder': os.path.abspath(target_path),
            'folder_exists': True,
            'total_files': len(files),
            'total_size': total_size,
            'total_size_readable': f"{total_size / (1024*1024):.2f} MB",
            'files': sorted(files, key=lambda x: x['modified'], reverse=True)
        }
    except Exception as e:
        add_debug_log('error', f"Error in debug files: {e}")
        return {'error': str(e)}

@app.post("/api/fix-yt-dlp")
async def fix_yt_dlp_endpoint():
    """Force clean reinstall of yt-dlp"""
    try:
        add_debug_log('info', "🛠️ Manual yt-dlp fix requested")
        if clean_install_yt_dlp():
            global youtube_dlp
            if initialize_yt_dlp():
                return {"message": "✅ yt-dlp fixed successfully!", "status": "fixed"}
            else:
                return {"message": "⚠️ yt-dlp reinstalled but import failed", "status": "partial"}
        else:
            return {"message": "❌ yt-dlp reinstallation failed", "status": "failed"}
    except Exception as e:
        add_debug_log('error', f"💥 Fix operation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Fix failed: {str(e)}")

@app.delete("/api/files/{filename}")
async def delete_file(filename: str, download_path: str = None):
    """Delete a downloaded file from specified path"""
    try:
        target_path = download_path if download_path and os.path.exists(download_path) else DEFAULT_DOWNLOAD_FOLDER
        filepath = os.path.join(target_path, filename)
        if os.path.exists(filepath):
            os.remove(filepath)
            add_debug_log('info', f"🗑️ Deleted file: {filename} from {target_path}")
            return {"message": f"File {filename} deleted successfully from {target_path}"}
        else:
            raise HTTPException(status_code=404, detail=f"File not found in {target_path}")
    except Exception as e:
        add_debug_log('error', f"Error deleting file: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/files")
async def clear_all_files(download_path: str = None):
    """Clear all downloaded files from specified path"""
    try:
        target_path = download_path if download_path and os.path.exists(download_path) else DEFAULT_DOWNLOAD_FOLDER
        deleted_count = 0
        for filename in os.listdir(target_path):
            filepath = os.path.join(target_path, filename)
            if os.path.isfile(filepath):
                os.remove(filepath)
                deleted_count += 1
        add_debug_log('info', f"🗑️ Cleared all files from {target_path}: {deleted_count} deleted")
        return {"message": f"All {deleted_count} files deleted successfully from {target_path}"}
    except Exception as e:
        add_debug_log('error', f"Error clearing files: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Error handler for uncaught exceptions
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    add_debug_log('error', f"🔥 Unhandled exception: {str(exc)}", {
        'path': request.url.path,
        'method': request.method,
        'query_params': dict(request.query_params)
    })
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "error_id": str(time.time())}
    )

if __name__ == "__main__":
    local_ip = get_local_ip()
    
    print("🚀 ===== UNIVERSAL MEDIA DOWNLOADER API v3.1.0 =====")
    print("📡 Server starting...")
    print(f"🌐 Use this URL in Flutter: http://{local_ip}:8000")
    print("===================================================")
    
    # Check system status
    yt_dlp_status = "✅ Working" if 'youtube_dlp' in globals() else "❌ Broken"
    ffmpeg_status = "✅ Available" if check_ffmpeg() else "❌ Not Found"
    
    print(f"📊 System Status:")
    print(f"   • yt-dlp: {yt_dlp_status}")
    print(f"   • FFmpeg: {ffmpeg_status}")
    print(f"   • Default download folder: {os.path.abspath(DEFAULT_DOWNLOAD_FOLDER)}")
    print(f"   • Supported platforms: {len(SUPPORTED_DOMAINS)}+ sites")
    print(f"   • Custom path support: ✅ Enabled")
    
    if ffmpeg_status == "❌ Not Found":
        print("\n⚠️  WARNING: FFmpeg not found!")
        print("   Audio conversion to MP3 may not work properly.")
        print("   Video+audio merging will not work.")
        print("   Please install FFmpeg for full functionality.")
    
    print("\n🔧 Available Endpoints:")
    print("   • GET  /api/health - System status")
    print("   • POST /api/info - Analyze URL")
    print("   • GET  /api/download-file - Download file (supports custom paths)")
    print("   • GET  /api/debug/logs - View debug logs")
    print("   • GET  /api/debug/files - List downloaded files")
    print("   • GET  /api/test-download - Test download")
    
    print("\n🛡️  Security Features:")
    print("   • URL validation and sanitization")
    print("   • Suspicious URL detection")
    print("   • Path validation and security checks")
    print("   • Comprehensive error handling")
    print("   • Request logging and monitoring")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")