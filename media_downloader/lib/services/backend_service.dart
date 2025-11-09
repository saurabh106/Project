import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BackendService {
  static const String _baseUrl = AppConstants.backendUrl;

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/health'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'yt_dlp_status': 'Offline'};
    } catch (e) {
      return {'yt_dlp_status': 'Offline'};
    }
  }

  static Future<Map<String, dynamic>> analyzeUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/info'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'url=${Uri.encodeComponent(url)}',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Analysis failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fixYtDlp() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fix-yt-dlp'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Fix failed with status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.StreamedResponse> downloadFile(
    String url, 
    String formatType, 
    String downloadPath
  ) async {
    final downloadUrl = '$_baseUrl/api/download-file?'
        'url=${Uri.encodeComponent(url)}&format_type=$formatType&download_path=${Uri.encodeComponent(downloadPath)}';
    
    final request = http.Request('GET', Uri.parse(downloadUrl));
    return await http.Client().send(request);
  }
}