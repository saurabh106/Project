import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/helpers.dart';
import 'backend_service.dart';

class DownloadService {
  static Future<String?> downloadWithFlutterDownloader(
    String downloadUrl, 
    String downloadPath, 
    String fileName
  ) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: downloadPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        requiresStorageNotLow: false,
        saveInPublicStorage: true,
        allowCellular: true,
      );
      return taskId;
    } catch (e) {
      print('Flutter Downloader failed: $e');
      return null;
    }
  }

  static Future<void> directDownload(
    String url,
    String formatType,
    String downloadPath,
    Function(String) onProgress,
    Function(String, String) onComplete,
    Function(String) onError,
  ) async {
    try {
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final infoData = await BackendService.analyzeUrl(url);
      final videoTitle = infoData['title'] ?? 'download';
      final safeTitle = videoTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final extension = formatType == 'audio' ? 'mp3' : 'mp4';
      final fileName = '$safeTitle.$extension';
      final filePath = '$downloadPath/$fileName';

      final request = await BackendService.downloadFile(url, formatType, downloadPath);
      
      if (request.statusCode != 200) {
        throw Exception('Download request failed: ${request.statusCode}');
      }

      final contentLength = request.contentLength;
      int receivedLength = 0;
      final file = File(filePath);
      final sink = file.openWrite();

      await request.stream.listen(
        (List<int> chunk) {
          receivedLength += chunk.length;
          sink.add(chunk);
          
          if (contentLength != null) {
            final progress = (receivedLength / contentLength * 100).toInt();
            if (progress % 10 == 0) {
              onProgress('Download progress: $progress%');
            }
          }
        },
        onDone: () async {
          await sink.close();
          onComplete(fileName, filePath);
        },
        onError: (error) {
          sink.close();
          onError('Download error: $error');
        },
        cancelOnError: true,
      ).asFuture();

    } catch (e) {
      onError('Direct download error: $e');
    }
  }
}