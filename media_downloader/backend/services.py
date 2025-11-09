import os
import re
import shutil
from urllib.parse import urlparse
from typing import Dict, Any, List
from config import config, add_debug_log, yt_dlp_manager

class Validator:
    """URL and path validation"""
    
    @staticmethod
    def validate_url(url: str) -> Dict[str, Any]:
        """Validate URL and detect platform"""
        try:
            add_debug_log('debug', f"🔍 Validating URL: {url}")
            
            parsed = urlparse(url)
            if not parsed.scheme or not parsed.netloc:
                return {'valid': False, 'error': 'Invalid URL format'}
            
            domain = parsed.netloc.lower()
            
            # Detect platform
            if 'youtube.com' in domain or 'youtu.be' in domain:
                platform = 'youtube'
            elif 'spotify.com' in domain:
                platform = 'spotify'
            elif 'soundcloud.com' in domain:
                platform = 'soundcloud'
            elif any(supported in domain for supported in config.SUPPORTED_DOMAINS):
                platform = 'supported'
            else:
                platform = 'unknown'
            
            for pattern in config.SUSPICIOUS_URL_PATTERNS:
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
    
    @staticmethod
    def validate_download_path(download_path: str = None) -> Dict[str, Any]:
        """Validate download path"""
        try:
            if not download_path or download_path == 'default':
                download_path = config.DEFAULT_DOWNLOAD_FOLDER
            
            if isinstance(download_path, str) and download_path.startswith('/storage/'):
                add_debug_log('info', f"📁 Android path detected, using default")
                download_path = config.DEFAULT_DOWNLOAD_FOLDER
            
            if not os.path.exists(download_path):
                os.makedirs(download_path, exist_ok=True)
            
            test_file = os.path.join(download_path, '.write_test')
            try:
                with open(test_file, 'w') as f:
                    f.write('test')
                os.remove(test_file)
            except Exception as e:
                return {
                    'valid': False,
                    'error': f'No write permission: {download_path}'
                }
            
            return {
                'valid': True,
                'download_path': download_path,
                'absolute_path': os.path.abspath(download_path)
            }
        except Exception as e:
            return {'valid': False, 'error': f'Invalid path: {str(e)}'}

validator = Validator()

class FileManager:
    """File operations and cleanup"""
    
    @staticmethod
    def find_best_downloaded_file(downloaded_filename: str, original_title: str,
                                  format_type: str, ffmpeg_available: bool,
                                  download_path: str) -> str:
        """Find best file and cleanup"""
        add_debug_log('debug', f"🔍 Finding best file for: {downloaded_filename}")
        
        base_name = os.path.splitext(os.path.basename(downloaded_filename))[0]
        base_name = base_name.split('.f')[0]
        
        matching_files = []
        for file in os.listdir(download_path):
            if file.startswith(base_name) and os.path.isfile(os.path.join(download_path, file)):
                file_path = os.path.join(download_path, file)
                file_size = os.path.getsize(file_path)
                matching_files.append((file_path, file_size, file))
        
        if not matching_files:
            return downloaded_filename
        
        if len(matching_files) == 1:
            best_file = matching_files[0][0]
        else:
            clean_files = [f for f in matching_files if '.f' not in f[2]]
            if clean_files:
                clean_files.sort(key=lambda x: x[1], reverse=True)
                best_file = clean_files[0][0]
            else:
                matching_files.sort(key=lambda x: x[1], reverse=True)
                best_file = matching_files[0][0]
        
        for file_path, _, file_name in matching_files:
            if file_path != best_file and '.f' in file_name:
                try:
                    os.remove(file_path)
                except:
                    pass
        
        return FileManager._ensure_extension(best_file, format_type, ffmpeg_available)
    
    @staticmethod
    def _ensure_extension(filename: str, format_type: str, ffmpeg_available: bool) -> str:
        """Ensure proper file extension"""
        if format_type == "audio":
            if not filename.lower().endswith(('.mp3', '.m4a', '.aac', '.opus')):
                ext = '.mp3' if ffmpeg_available else '.m4a'
                new_filename = os.path.splitext(filename)[0] + ext
                if new_filename != filename and not os.path.exists(new_filename):
                    try:
                        shutil.move(filename, new_filename)
                        return new_filename
                    except:
                        pass
        else:
            video_exts = ('.mp4', '.mkv', '.webm', '.avi', '.mov')
            if not filename.lower().endswith(video_exts):
                new_filename = os.path.splitext(filename)[0] + '.mp4'
                if new_filename != filename and not os.path.exists(new_filename):
                    try:
                        shutil.move(filename, new_filename)
                        return new_filename
                    except:
                        pass
        return filename

file_manager = FileManager()

class DownloadService:
    """Main download service"""
    
    def download_media(self, url: str, format_type: str = "best", 
                      download_path: str = None) -> Dict[str, Any]:
        """Download media from URL"""
        youtube_dlp = yt_dlp_manager.youtube_dlp
        if not youtube_dlp:
            return {'success': False, 'error': 'yt-dlp not initialized', 'url': url}
        
        add_debug_log('info', f"🚀 Starting download - URL: {url}")
        
        url_validation = validator.validate_url(url)
        if not url_validation['valid']:
            return {
                'success': False,
                'title': 'Invalid URL',
                'error': url_validation['error'],
                'url': url,
                'platform': url_validation.get('platform', 'unknown')
            }
        
        path_validation = validator.validate_download_path(download_path)
        if not path_validation['valid']:
            return {
                'success': False,
                'title': 'Path Error',
                'error': path_validation['error'],
                'url': url,
                'platform': url_validation['platform']
            }
        
        actual_path = path_validation['download_path']
        platform = url_validation['platform']
        
        ydl_opts = yt_dlp_manager.get_ydl_opts(format_type, actual_path)
        
        try:
            with youtube_dlp.YoutubeDL(ydl_opts) as ydl:
                try:
                    info = ydl.extract_info(url, download=False, process=False)
                    if not info:
                        raise Exception('Video not available')
                except Exception as info_error:
                    try:
                        info = ydl.extract_info(url, download=False)
                        if not info:
                            raise info_error
                    except:
                        return {
                            'success': False,
                            'title': 'Unknown',
                            'error': f'Cannot access video: {str(info_error)}',
                            'url': url,
                            'platform': platform
                        }
                
                title = info.get('title', 'Unknown')
                duration = info.get('duration', 0)
                uploader = info.get('uploader', 'Unknown')
                
                add_debug_log('info', f"✅ Video: '{title}' by {uploader}")
                
                info = ydl.extract_info(url, download=True)
                downloaded_filename = ydl.prepare_filename(info)
                
                final_filename = file_manager.find_best_downloaded_file(
                    downloaded_filename, title, format_type,
                    yt_dlp_manager.ffmpeg_available, actual_path
                )
                
                if not os.path.exists(final_filename):
                    raise Exception(f'File not found: {final_filename}')
                
                file_size = os.path.getsize(final_filename)
                add_debug_log('info', f"✅ Download complete: {final_filename}")
                
                return {
                    'success': True,
                    'title': title,
                    'filename': os.path.basename(final_filename),
                    'filepath': final_filename,
                    'duration': duration,
                    'file_size': file_size,
                    'url': url,
                    'format': format_type,
                    'has_ffmpeg': yt_dlp_manager.ffmpeg_available,
                    'platform': platform,
                    'uploader': uploader,
                    'download_path': actual_path
                }
        except Exception as e:
            error_msg = str(e)
            add_debug_log('error', f"❌ Download failed: {error_msg}")
            
            user_error = self._parse_error(error_msg)
            
            return {
                'success': False,
                'title': 'Unknown',
                'error': user_error,
                'url': url,
                'platform': platform,
                'download_path': actual_path,
                'debug_info': error_msg[:500]
            }
    
    def get_playlist_info(self, url: str) -> Dict[str, Any]:
        """Get playlist information"""
        youtube_dlp = yt_dlp_manager.youtube_dlp
        if not youtube_dlp:
            raise Exception("yt-dlp not initialized")
        
        url_validation = validator.validate_url(url)
        if not url_validation['valid']:
            raise Exception(url_validation['error'])
        
        ydl_opts = {
            'quiet': True,
            'extract_flat': 'in_playlist',
            'no_warnings': False,
            'ignoreerrors': True,
        }
        
        with youtube_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            if not info:
                raise Exception("Could not extract information")
            
            if 'entries' in info:
                videos = []
                available = 0
                unavailable = 0
                
                for entry in info['entries']:
                    if entry and entry.get('title'):
                        videos.append({
                            'title': entry.get('title', 'Unknown'),
                            'url': entry.get('url', ''),
                            'webpage_url': entry.get('webpage_url', ''),
                            'id': entry.get('id', ''),
                            'duration': entry.get('duration', 0),
                            'available': True
                        })
                        available += 1
                    else:
                        videos.append({
                            'title': 'Unavailable Video',
                            'available': False
                        })
                        unavailable += 1
                
                return {
                    'title': info.get('title', 'Unknown Playlist'),
                    'uploader': info.get('uploader', 'Unknown'),
                    'video_count': len(videos),
                    'available_videos': available,
                    'unavailable_videos': unavailable,
                    'videos': videos,
                    'type': 'playlist',
                    'platform': url_validation['platform']
                }
            else:
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
                        'available': True
                    }],
                    'type': 'single',
                    'platform': url_validation['platform']
                }
    
    def _parse_error(self, error_msg: str) -> str:
        """Parse error messages"""
        error_map = {
            '403': "YouTube blocked (403). Try again later.",
            'Forbidden': "Access forbidden. Video restricted.",
            'Private video': "Video is private",
            'Members-only': "Members-only video",
            'Video unavailable': "Video not available",
            'FFmpeg': "FFmpeg not available",
        }
        
        for key, message in error_map.items():
            if key.lower() in error_msg.lower():
                return message
        
        return error_msg.split('ERROR:')[-1].strip().split('\n')[0] if 'ERROR:' in error_msg else error_msg

download_service = DownloadService()