from fastapi import FastAPI, HTTPException, Form, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import uvicorn
import os
import shutil
import time
from datetime import datetime
from config import config, add_debug_log, get_local_ip, debug_logs, yt_dlp_manager
from services import download_service, validator

app = FastAPI(
    title=config.API_TITLE,
    description="Advanced media downloader supporting YouTube, Spotify, and 1000+ sites",
    version=config.API_VERSION
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    add_debug_log('info', f"🚀 {config.API_TITLE} v{config.API_VERSION} Starting...")
    if not yt_dlp_manager.initialize():
        add_debug_log('warning', "🔄 yt-dlp initialization failed, attempting reinstall...")
        if yt_dlp_manager.clean_install():
            yt_dlp_manager.initialize()
    add_debug_log('info', "✅ Application startup complete")

@app.get("/")
async def root():
    """Root endpoint with API information"""
    local_ip = get_local_ip()
    yt_dlp_status = "✅ Working" if yt_dlp_manager.youtube_dlp else "❌ Broken"
    ffmpeg_status = "✅ Available" if yt_dlp_manager.ffmpeg_available else "❌ Not Found"
    
    return {
        "message": config.API_TITLE,
        "status": "healthy",
        "version": config.API_VERSION,
        "local_ip": local_ip,
        "yt_dlp_status": yt_dlp_status,
        "ffmpeg_status": ffmpeg_status,
        "default_download_folder": config.DEFAULT_DOWNLOAD_FOLDER,
        "supported_platforms": config.SUPPORTED_DOMAINS,
        "features": [
            "YouTube, Spotify, SoundCloud support",
            "1000+ websites via yt-dlp",
            "MP4 Video & MP3 Audio downloads",
            "Custom download path support",
            "Playlist analysis",
            "Advanced error handling"
        ],
        "endpoints": [
            "GET /api/health - System status",
            "POST /api/info - Analyze URL",
            "POST /api/download - Download media",
            "GET /api/download-file - Direct file download",
            "GET /api/debug/logs - View logs",
            "GET /api/debug/files - List files"
        ],
        "access_urls": [
            f"http://localhost:{config.PORT}",
            f"http://127.0.0.1:{config.PORT}",
            f"http://{local_ip}:{config.PORT}"
        ]
    }

@app.get("/api/health")
async def health_check():
    """System health check"""
    yt_dlp_status = "✅ Working" if yt_dlp_manager.youtube_dlp else "❌ Broken"
    ffmpeg_status = "✅ Available" if yt_dlp_manager.ffmpeg_available else "❌ Not Found"
    
    try:
        disk_usage = shutil.disk_usage(config.DEFAULT_DOWNLOAD_FOLDER)
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
        "version": config.API_VERSION,
        "timestamp": datetime.now().isoformat(),
        "default_download_folder": os.path.abspath(config.DEFAULT_DOWNLOAD_FOLDER),
        "download_folder_exists": os.path.exists(config.DEFAULT_DOWNLOAD_FOLDER)
    }

@app.post("/api/info")
async def get_info(url: str = Form(...)):
    """Get information about a URL (video or playlist)"""
    add_debug_log('info', f"📊 Info request for: {url}")
    try:
        info = download_service.get_playlist_info(url)
        add_debug_log('info', f"✅ Info retrieval successful: {info['title']}")
        return info
    except Exception as e:
        add_debug_log('error', f"💥 Info error: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Analysis failed: {str(e)}")

@app.post("/api/download")
async def download_url(
    url: str = Form(...),
    format_type: str = Form("best"),
    download_path: str = Form(None)
):
    """Download media (returns metadata)"""
    add_debug_log('info', f"⬇️ Download request - URL: {url}")
    try:
        result = download_service.download_media(url, format_type, download_path)
        return result
    except Exception as e:
        add_debug_log('error', f"💥 Download error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/download-file")
async def download_file(
    url: str,
    format_type: str = "best",
    download_path: str = None
):
    """Direct file download (for mobile apps)"""
    add_debug_log('info', f"📥 Download file request - URL: {url}")
    
    try:
       
        try:
            playlist_info = download_service.get_playlist_info(url)
            if playlist_info['type'] == 'playlist':
                available_videos = [v for v in playlist_info['videos'] 
                                  if v['available'] and (v.get('url') or v.get('webpage_url'))]
                if available_videos:
                    first_video = available_videos[0]
                    video_url = first_video.get('url') or first_video.get('webpage_url')
                    if video_url:
                        url = video_url
                        add_debug_log('info', "🎵 Using first video from playlist")
        except Exception as e:
            add_debug_log('warning', f"⚠️ Playlist detection failed: {e}")
        
        
        result = download_service.download_media(url, format_type, download_path)
        
        if result['success'] and os.path.exists(result['filepath']):
            media_type = 'audio/mpeg' if format_type == "audio" else 'video/mp4'
            
            return FileResponse(
                result['filepath'],
                filename=result['filename'],
                media_type=media_type,
                headers={
                    'Content-Disposition': f'attachment; filename="{result["filename"]}"',
                    'X-File-Size': str(result['file_size']),
                    'X-Duration': str(result['duration']),
                    'X-Platform': result['platform']
                }
            )
        else:
            raise HTTPException(status_code=400, detail=result.get('error', 'Download failed'))
            
    except HTTPException:
        raise
    except Exception as e:
        add_debug_log('error', f"💥 Download file error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Download error: {str(e)}")

@app.get("/api/debug/logs")
async def get_logs(limit: int = 100, level: str = None):
    """Get debug logs"""
    filtered_logs = debug_logs
    if level:
        filtered_logs = [log for log in debug_logs if log['level'] == level.lower()]
    
    return {
        'total_logs': len(debug_logs),
        'filtered_logs': len(filtered_logs),
        'logs': filtered_logs[-limit:]
    }

@app.delete("/api/debug/logs")
async def clear_logs():
    """Clear debug logs"""
    global debug_logs
    debug_logs.clear()
    add_debug_log('info', "🗑️ Debug logs cleared")
    return {"message": "Debug logs cleared successfully"}

@app.get("/api/debug/files")
async def debug_files(download_path: str = None):
    """List downloaded files"""
    files = []
    total_size = 0
    
    try:
        target_path = download_path if download_path and os.path.exists(download_path) else config.DEFAULT_DOWNLOAD_FOLDER
        
        if not os.path.exists(target_path):
            return {'error': 'Download folder does not exist', 'download_folder': target_path}
            
        for filename in os.listdir(target_path):
            filepath = os.path.join(target_path, filename)
            if os.path.isfile(filepath):
                stat = os.stat(filepath)
                files.append({
                    'name': filename,
                    'size': stat.st_size,
                    'path': filepath,
                    'modified': stat.st_mtime,
                    'modified_readable': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S'),
                    'extension': os.path.splitext(filename)[1].lower()
                })
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
        return {'error': str(e)}

@app.post("/api/debug/fix-yt-dlp")
async def fix_yt_dlp():
    """Reinstall yt-dlp"""
    try:
        add_debug_log('info', "🛠️ Manual yt-dlp fix requested")
        if yt_dlp_manager.clean_install():
            if yt_dlp_manager.initialize():
                return {"message": "✅ yt-dlp fixed successfully!", "status": "fixed"}
            else:
                return {"message": "⚠️ Reinstalled but import failed", "status": "partial"}
        else:
            return {"message": "❌ Reinstallation failed", "status": "failed"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fix failed: {str(e)}")

@app.delete("/api/files/{filename}")
async def delete_file(filename: str, download_path: str = None):
    """Delete a downloaded file"""
    try:
        target_path = download_path if download_path and os.path.exists(download_path) else config.DEFAULT_DOWNLOAD_FOLDER
        filepath = os.path.join(target_path, filename)
        if os.path.exists(filepath):
            os.remove(filepath)
            add_debug_log('info', f"🗑️ Deleted file: {filename}")
            return {"message": f"File {filename} deleted successfully"}
        else:
            raise HTTPException(status_code=404, detail="File not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/files")
async def clear_all_files(download_path: str = None):
    """Clear all downloaded files"""
    try:
        target_path = download_path if download_path and os.path.exists(download_path) else config.DEFAULT_DOWNLOAD_FOLDER
        deleted_count = 0
        for filename in os.listdir(target_path):
            filepath = os.path.join(target_path, filename)
            if os.path.isfile(filepath):
                os.remove(filepath)
                deleted_count += 1
        add_debug_log('info', f"🗑️ Cleared {deleted_count} files")
        return {"message": f"{deleted_count} files deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler"""
    add_debug_log('error', f"🔥 Unhandled exception: {str(exc)}", {
        'path': request.url.path,
        'method': request.method
    })
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error", "error_id": str(time.time())}
    )

if __name__ == "__main__":
    local_ip = get_local_ip()
    
    print("=" * 60)
    print(f"🚀 {config.API_TITLE} v{config.API_VERSION}")
    print("=" * 60)
    print(f"\n📡 Server Configuration:")
    print(f"   • Host: {config.HOST}")
    print(f"   • Port: {config.PORT}")
    print(f"   • Local IP: {local_ip}")
    
    print(f"\n🌐 Access URLs:")
    print(f"   • http://localhost:{config.PORT}")
    print(f"   • http://127.0.0.1:{config.PORT}")
    print(f"   • http://{local_ip}:{config.PORT}")
    
    print(f"\n📂 Download Folder:")
    print(f"   • {config.DEFAULT_DOWNLOAD_FOLDER}")
    
    print(f"\n🔧 System Status:")
    yt_status = "✅ Ready" if yt_dlp_manager.youtube_dlp else "⚠️ Not initialized"
    ff_status = "✅ Available" if yt_dlp_manager.ffmpeg_available else "⚠️ Not found"
    print(f"   • yt-dlp: {yt_status}")
    print(f"   • FFmpeg: {ff_status}")
    
    if not yt_dlp_manager.ffmpeg_available:
        print(f"\n⚠️  WARNING: FFmpeg not found!")
        print(f"   Install FFmpeg for full functionality")
    
    print(f"\n📚 Key Endpoints:")
    print(f"   • GET  /api/health - System status")
    print(f"   • POST /api/info - Analyze URL")
    print(f"   • POST /api/download - Download media")
    print(f"   • GET  /api/download-file - Direct download")
    print(f"   • GET  /api/debug/logs - View logs")
    
    print("\n" + "=" * 60)
    print("🚀 Starting server...")
    print("=" * 60 + "\n")
    
    uvicorn.run(app, host=config.HOST, port=config.PORT, log_level="info")