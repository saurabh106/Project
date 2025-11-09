class DownloadItem {
  final String title;
  final String url;
  final String format;
  final String timestamp;
  final String filename;
  final String? filePath;
  final String? taskId;
  final String status;
  final String method;
  final bool success;
  final String downloadPath;

  DownloadItem({
    required this.title,
    required this.url,
    required this.format,
    required this.timestamp,
    required this.filename,
    this.filePath,
    this.taskId,
    required this.status,
    required this.method,
    required this.success,
    required this.downloadPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'format': format,
      'timestamp': timestamp,
      'filename': filename,
      'file_path': filePath,
      'task_id': taskId,
      'status': status,
      'method': method,
      'success': success,
      'download_path': downloadPath,
    };
  }

  static DownloadItem fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      title: map['title'],
      url: map['url'],
      format: map['format'],
      timestamp: map['timestamp'],
      filename: map['filename'],
      filePath: map['file_path'],
      taskId: map['task_id'],
      status: map['status'],
      method: map['method'],
      success: map['success'],
      downloadPath: map['download_path'],
    );
  }
}

class MediaInfo {
  final String type;
  final String title;
  final String? platform;
  final int videoCount;
  final List<dynamic>? videos;

  MediaInfo({
    required this.type,
    required this.title,
    this.platform,
    required this.videoCount,
    this.videos,
  });

  factory MediaInfo.fromMap(Map<String, dynamic> map) {
    return MediaInfo(
      type: map['type'] ?? 'unknown',
      title: map['title'] ?? 'Unknown',
      platform: map['platform'],
      videoCount: map['video_count'] ?? 0,
      videos: map['videos'],
    );
  }
}