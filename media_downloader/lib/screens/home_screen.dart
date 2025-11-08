// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_import, avoid_print, unused_element, unrelated_type_equality_checks, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _downloading = false;
  bool _analyzing = false;
  bool _fixingYtDlp = false;
  Map<String, dynamic>? _mediaInfo;
  String _selectedFormat = 'best';
  final List<Map<String, dynamic>> _downloadHistory = [];
  List<String> _debugLogs = [];
  String _backendStatus = 'Checking...';
  bool _permissionGranted = false;
  bool _checkingPermission = true;
  String _selectedPath = 'Default Download Folder';
  bool _selectingPath = false;

  // Update this to your Python backend URL
  static const String _backendUrl = 'http://192.168.0.106:8000';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _addDebugLog('🚀 Initializing app...');
    
    // Step 1: Request permissions first
    await _requestPermissions();
    
    // Step 2: Initialize downloader
    await _initializeDownloader();
    
    // Step 3: Check backend status
    await _checkBackendStatus();
    
    // Step 4: Initialize default download path
    await _initializeDefaultPath();
    
    setState(() {
      _checkingPermission = false;
    });
  }

  Future<void> _initializeDefaultPath() async {
    try {
      final directory = await getExternalStorageDirectory();
      final downloadPath = '${directory?.path}/Download';
      setState(() {
        _selectedPath = _getUserFriendlyPath(downloadPath);
      });
      _addDebugLog('📁 Default download path: $downloadPath');
    } catch (e) {
      _addDebugLog('❌ Error setting default path: $e');
    }
  }

  Future<void> _requestPermissions() async {
    _addDebugLog('🔐 Requesting storage permissions...');
    
    try {
      // Request storage permission
      var storageStatus = await Permission.storage.status;
      
      if (!storageStatus.isGranted) {
        _addDebugLog('📁 Storage permission not granted, requesting...');
        storageStatus = await Permission.storage.request();
      }
      
      // Also request manage external storage for Android 10+
      var manageStorageStatus = await Permission.manageExternalStorage.status;
      if (!manageStorageStatus.isGranted) {
        manageStorageStatus = await Permission.manageExternalStorage.request();
      }
      
      // Check if we have sufficient permissions
      if (storageStatus.isGranted || manageStorageStatus.isGranted) {
        _addDebugLog('✅ Storage permissions granted');
        setState(() {
          _permissionGranted = true;
        });
        
        // Verify we can access download directory
        await _verifyDownloadAccess();
      } else {
        _addDebugLog('❌ Storage permissions denied');
        setState(() {
          _permissionGranted = false;
        });
        _showSnackBar('Storage permission required for downloads');
      }
    } catch (e) {
      _addDebugLog('💥 Permission error: $e');
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  Future<void> _verifyDownloadAccess() async {
    try {
      final directory = await getExternalStorageDirectory();
      final downloadPath = '${directory?.path}/Download';
      final downloadDir = Directory(downloadPath);
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
        _addDebugLog('📁 Created download directory: $downloadPath');
      }
      
      // Try to create a test file to verify write access
      final testFile = File('$downloadPath/.test_write_access');
      await testFile.writeAsString('test', flush: true);
      await testFile.delete();
      
      _addDebugLog('✅ Write access verified in download directory');
    } catch (e) {
      _addDebugLog('❌ Write access denied: $e');
      setState(() {
        _permissionGranted = false;
      });
    }
  }

String _getUserFriendlyPath(String fullPath) {
  if (fullPath.contains('/storage/emulated/0/')) {
    final displayPath = fullPath.replaceFirst('/storage/emulated/0/', '');
    return 'Internal Storage/$displayPath';
  } else if (fullPath.contains('/storage/')) {
    final parts = fullPath.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      final storageName = parts[2];
      final displayPath = fullPath.replaceFirst('/storage/$storageName/', '');
      return '$storageName/$displayPath';
    }
  }
  return fullPath; // fallback
}

  String _getFullPathFromUserFriendly(String userFriendlyPath) {
    // Convert user-friendly path back to full system path
    if (userFriendlyPath.startsWith('Internal Storage')) {
      return '/storage/emulated/0/' + userFriendlyPath.substring('Internal Storage'.length);
    } else if (userFriendlyPath.startsWith('Storage (')) {
      // Extract storage name and reconstruct full path
      final match = RegExp(r'Storage \(([^)]+)\)(.+)').firstMatch(userFriendlyPath);
      if (match != null) {
        final storageName = match.group(1)!;
        final pathSuffix = match.group(2)!;
        return '/storage/$storageName$pathSuffix';
      }
    }
    
    return userFriendlyPath;
  }

  Future<void> _selectDownloadPath() async {
    if (!_permissionGranted) {
      _showSnackBar('Please grant storage permission first');
      await _requestPermissions();
      return;
    }

    _addDebugLog('📁 Opening directory picker...');
    setState(() {
      _selectingPath = true;
    });

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Download Folder',
        lockParentWindow: true,
      );

      if (selectedDirectory != null) {
        _addDebugLog('✅ Selected directory: $selectedDirectory');
        
        // Verify write access to selected directory
        try {
          final testFile = File('$selectedDirectory/.test_write_access');
          await testFile.writeAsString('test', flush: true);
          await testFile.delete();
          
          setState(() {
            _selectedPath = _getUserFriendlyPath(selectedDirectory);
          });
          _addDebugLog('✅ Write access verified in selected directory');
          _showSnackBar('Download location updated!');
        } catch (e) {
          _addDebugLog('❌ No write access to selected directory: $e');
          _showSnackBar('Cannot write to selected folder. Choose a different location.');
        }
      } else {
        _addDebugLog('ℹ️ User cancelled directory selection');
      }
    } catch (e) {
      _addDebugLog('💥 Directory selection error: $e');
      _showSnackBar('Error selecting folder: $e');
    } finally {
      setState(() {
        _selectingPath = false;
      });
    }
  }

  Future<void> _resetToDefaultPath() async {
    try {
      final directory = await getExternalStorageDirectory();
      final downloadPath = '${directory?.path}/Download';
      
      setState(() {
        _selectedPath = _getUserFriendlyPath(downloadPath);
      });
      _addDebugLog('🔄 Reset to default path: $downloadPath');
      _showSnackBar('Reset to default download folder');
    } catch (e) {
      _addDebugLog('❌ Error resetting to default path: $e');
      _showSnackBar('Error resetting download folder');
    }
  }

  Future<void> _initializeDownloader() async {
    try {
      await FlutterDownloader.initialize(debug: true);
      _addDebugLog('✅ Flutter Downloader initialized');
      
      // Setup download listener
      _setupDownloadListener();
    } catch (e) {
      _addDebugLog('❌ Flutter Downloader init failed: $e');
    }
  }

  void _addDebugLog(String message) {
    final timestamp = DateTime.now().toString().split(' ')[1].split('.')[0];
    setState(() {
      _debugLogs.insert(0, '[DEBUG $timestamp] $message');
    });
    print('📱 FLUTTER DEBUG: $message');
  }

  void _clearDebugLogs() {
    setState(() {
      _debugLogs.clear();
    });
  }

  Future<void> _checkBackendStatus() async {
    _addDebugLog('🔍 Checking backend status...');
    try {
      final response = await http.get(Uri.parse('$_backendUrl/api/health'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _backendStatus = data['yt_dlp_status'] ?? 'Unknown';
        });
        _addDebugLog('✅ Backend status: $_backendStatus');
      }
    } catch (e) {
      _addDebugLog('❌ Failed to check backend status: $e');
      setState(() {
        _backendStatus = 'Offline';
      });
    }
  }

  Future<void> _fixYtDlp() async {
    _addDebugLog('🛠️ Fixing yt-dlp installation...');
    setState(() => _fixingYtDlp = true);

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/fix-yt-dlp'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _addDebugLog('✅ ${result['message']}');
        _showSnackBar(result['message']);
        await _checkBackendStatus();
      } else {
        _addDebugLog('❌ Fix failed with status: ${response.statusCode}');
        _showSnackBar('Failed to fix yt-dlp');
      }
    } catch (e) {
      _addDebugLog('💥 Fix error: $e');
      _showSnackBar('Fix error: $e');
    } finally {
      setState(() => _fixingYtDlp = false);
    }
  }

  Future<void> _analyzeUrl() async {
    if (!_permissionGranted) {
      _showSnackBar('Please grant storage permission first');
      await _requestPermissions();
      return;
    }

    final url = _controller.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Please enter a URL');
      return;
    }

    _addDebugLog('🔍 Starting URL analysis: $url');
    setState(() {
      _analyzing = true;
      _mediaInfo = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/info'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'url=${Uri.encodeComponent(url)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addDebugLog('✅ Analysis successful - Type: ${data['type']}, Videos: ${data['video_count']}');
        setState(() {
          _mediaInfo = data;
        });
      } else {
        final error = json.decode(response.body);
        _addDebugLog('❌ Analysis failed: ${error['detail']}');
        _showSnackBar('Error: ${error['detail']}');
      }
    } catch (e) {
      _addDebugLog('💥 Connection error: $e');
      _showSnackBar('Connection error: $e');
    } finally {
      setState(() => _analyzing = false);
    }
  }

 Future<void> _startDownload() async {
  if (!_permissionGranted) {
    _showSnackBar('Please grant storage permission first');
    await _requestPermissions();
    return;
  }

  final url = _controller.text.trim();
  if (url.isEmpty) {
    _showSnackBar('Please enter a URL');
    return;
  }

  setState(() => _downloading = true);

  try {
    final fullDownloadPath = _getFullPathFromUserFriendly(_selectedPath);

    // Make a request to the backend only to let it fetch/process the video
    final downloadUrl = '$_backendUrl/api/download-file?'
        'url=${Uri.encodeComponent(url)}&format_type=$_selectedFormat';

    final response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode == 200) {
      // Extract filename from backend response
      final contentDisposition = response.headers['content-disposition'];
      final fileName = RegExp(r'filename="(.+)"')
          .firstMatch(contentDisposition ?? '')
          ?.group(1) ?? 'download.mp4';

      // Save the file locally on the phone
      final filePath = '$fullDownloadPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes, flush: true);

      _addDebugLog('✅ File saved locally: $filePath');
      _showSnackBar('Download completed: $fileName');

      // Add to history
      _downloadHistory.insert(0, {
        'title': fileName,
        'url': url,
        'format': _selectedFormat,
        'timestamp': DateTime.now().toString(),
        'filename': fileName,
        'file_path': filePath,
        'status': 'completed',
        'method': 'flutter_direct_download',
        'success': true,
        'download_path': _selectedPath,
      });
    } else {
      _showSnackBar('Backend error: ${response.statusCode}');
      _addDebugLog('❌ Backend response status: ${response.statusCode}');
    }
  } catch (e) {
    _showSnackBar('Error: $e');
    _addDebugLog('❌ Download error: $e');
  } finally {
    setState(() => _downloading = false);
  }
}

  Future<void> _downloadWithFlutterDownloader(String downloadUrl, String downloadPath, String fileName, String videoTitle, String originalUrl) async {
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

      if (taskId != null) {
        _addDebugLog('✅ Download started successfully! Task ID: $taskId');
        _showSnackBar('Download started: $fileName');
        
        // Add to history
        _downloadHistory.insert(0, {
          'title': videoTitle,
          'url': originalUrl,
          'format': _selectedFormat,
          'timestamp': DateTime.now().toString(),
          'filename': fileName,
          'task_id': taskId,
          'status': 'downloading',
          'method': 'flutter_downloader',
          'success': true,
          'download_path': _selectedPath, // Store user-friendly path
        });
        
        setState(() {});
      } else {
        throw Exception('Flutter Downloader failed - no task ID');
      }
    } catch (e) {
      _addDebugLog('❌ Flutter Downloader failed: $e');
      _addDebugLog('🔄 Falling back to direct download...');
      await _directDownload(originalUrl);
    }
  }

  void _setupDownloadListener() {
    FlutterDownloader.registerCallback((id, status, progress) {
      _addDebugLog('📱 Download callback - ID: $id, Status: $status, Progress: $progress');
      
      if (status == DownloadTaskStatus.complete) {
        _addDebugLog('✅ Download completed: $id');
        _showSnackBar('Download completed!');
        
        // Update history
        _updateDownloadStatus(id, 'completed');
        
        // Set downloading to false
        if (mounted) {
          setState(() => _downloading = false);
        }
      } else if (status == DownloadTaskStatus.failed) {
        _addDebugLog('❌ Download failed: $id');
        _showSnackBar('Download failed!');
        
        // Update history
        _updateDownloadStatus(id, 'failed');
        
        // Set downloading to false
        if (mounted) {
          setState(() => _downloading = false);
        }
      } else if (status == DownloadTaskStatus.running) {
        _addDebugLog('📥 Download progress: $progress%');
      }
    });
  }

  void _updateDownloadStatus(String taskId, String status) {
    for (int i = 0; i < _downloadHistory.length; i++) {
      if (_downloadHistory[i]['task_id'] == taskId) {
        setState(() {
          _downloadHistory[i]['status'] = status;
          _downloading = status != 'completed' && status != 'failed';
        });
        break;
      }
    }
  }

  Future<void> _directDownload(String url) async {
    _addDebugLog('🚀 Starting direct download...');

    try {
      // Convert user-friendly path back to full system path
      final fullDownloadPath = _getFullPathFromUserFriendly(_selectedPath);
      
      // Ensure download directory exists
      final downloadDir = Directory(fullDownloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Get video info for filename
      final infoResponse = await http.post(
        Uri.parse('$_backendUrl/api/info'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'url=${Uri.encodeComponent(url)}',
      );

      if (infoResponse.statusCode != 200) {
        throw Exception('Failed to get video info');
      }

      final infoData = json.decode(infoResponse.body);
      final videoTitle = infoData['title'] ?? 'download';
      String safeTitle = videoTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      String extension = _selectedFormat == 'audio' ? 'mp3' : 'mp4';
      String fileName = '$safeTitle.$extension';
      String filePath = '$fullDownloadPath/$fileName';

      _addDebugLog('📥 Downloading to: $filePath');

      // Create the download request with custom path
      final downloadUrl = '$_backendUrl/api/download-file?url=${Uri.encodeComponent(url)}&format_type=$_selectedFormat&download_path=${Uri.encodeComponent(fullDownloadPath)}';
      final request = await http.Client().send(http.Request('GET', Uri.parse(downloadUrl)));

      if (request.statusCode != 200) {
        throw Exception('Download request failed: ${request.statusCode}');
      }

      // Get file size for progress
      final contentLength = request.contentLength;
      int receivedLength = 0;

      // Open file for writing
      final file = File(filePath);
      final sink = file.openWrite();

      // Stream the response and save to file
      await request.stream.listen(
        (List<int> chunk) {
          receivedLength += chunk.length;
          sink.add(chunk);
          
          // Calculate progress
          if (contentLength != null) {
            final progress = (receivedLength / contentLength * 100).toInt();
            if (progress % 10 == 0) { // Log every 10% to avoid spam
              _addDebugLog('📊 Download progress: $progress%');
            }
          }
        },
        onDone: () async {
          await sink.close();
          _addDebugLog('✅ Download completed: $filePath');
          _showSnackBar('Download completed: $fileName');
          
          // Add to history
          _downloadHistory.insert(0, {
            'title': videoTitle,
            'url': url,
            'format': _selectedFormat,
            'timestamp': DateTime.now().toString(),
            'filename': fileName,
            'file_path': filePath,
            'status': 'completed',
            'method': 'direct_download',
            'success': true,
            'download_path': _selectedPath, // Store user-friendly path
          });
          
          setState(() => _downloading = false);
        },
        onError: (error) {
          sink.close();
          _addDebugLog('❌ Download error: $error');
          _showSnackBar('Download failed: $error');
          setState(() => _downloading = false);
        },
        cancelOnError: true,
      ).asFuture();

    } catch (e) {
      _addDebugLog('💥 Direct download error: $e');
      _showSnackBar('Download error: $e');
      setState(() => _downloading = false);
    }
  }

  Future<void> _checkDownloadPath() async {
    _addDebugLog('📁 Checking download path...');
    try {
      final fullDownloadPath = _getFullPathFromUserFriendly(_selectedPath);
      final downloadDir = Directory(fullDownloadPath);
      
      _addDebugLog('💾 Current download path: $fullDownloadPath');
      
      if (await downloadDir.exists()) {
        final files = downloadDir.listSync();
        _addDebugLog('📂 Found ${files.length} files in download folder:');
        for (final file in files) {
          if (file is File) {
            final size = await file.length();
            _addDebugLog('   - ${file.path.split('/').last} (${_formatFileSize(size)})');
          }
        }
        _showSnackBar('Found ${files.length} files in download folder');
      } else {
        _addDebugLog('❌ Download folder does not exist');
        _showSnackBar('Download folder not found');
      }
    } catch (e) {
      _addDebugLog('💥 Error checking download path: $e');
      _showSnackBar('Error checking download path');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _getShortPath(String fullPath) {
    // Use the user-friendly path for display
    final userFriendlyPath = _getUserFriendlyPath(fullPath);
    
    if (userFriendlyPath.length > 40) {
      return '...${userFriendlyPath.substring(userFriendlyPath.length - 37)}';
    }
    return userFriendlyPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Downloader'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_logs') _clearDebugLogs();
              else if (value == 'view_logs') _showDebugDialog();
              else if (value == 'check_path') _checkDownloadPath();
              else if (value == 'fix_ytdlp') _fixYtDlp();
              else if (value == 'check_status') _checkBackendStatus();
              else if (value == 'test_download') _testDownload();
              else if (value == 'request_permission') _requestPermissions();
              else if (value == 'select_path') _selectDownloadPath();
              else if (value == 'reset_path') _resetToDefaultPath();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'check_status',
                child: ListTile(
                  leading: Icon(
                    _backendStatus.contains('✅') ? Icons.check_circle : Icons.error,
                    color: _backendStatus.contains('✅') ? Colors.green : Colors.red,
                  ),
                  title: Text('Status: $_backendStatus'),
                ),
              ),
              PopupMenuItem(
                value: 'request_permission',
                child: ListTile(
                  leading: Icon(
                    _permissionGranted ? Icons.check_circle : Icons.warning,
                    color: _permissionGranted ? Colors.green : Colors.orange,
                  ),
                  title: Text(_permissionGranted ? 'Permissions: Granted' : 'Permissions: Needed'),
                ),
              ),
              PopupMenuItem(
                value: 'select_path',
                child: ListTile(
                  leading: _selectingPath 
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.folder_open),
                  title: const Text('Select Download Folder'),
                ),
              ),
              PopupMenuItem(
                value: 'reset_path',
                child: const ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Reset to Default Folder'),
                ),
              ),
              const PopupMenuItem(
                value: 'view_logs',
                child: ListTile(
                  leading: Icon(Icons.bug_report),
                  title: Text('View Debug Logs'),
                ),
              ),
              const PopupMenuItem(
                value: 'clear_logs',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear Debug Logs'),
                ),
              ),
              const PopupMenuItem(
                value: 'check_path',
                child: ListTile(
                  leading: Icon(Icons.folder_open),
                  title: Text('Check Download Path'),
                ),
              ),
              PopupMenuItem(
                value: 'fix_ytdlp',
                child: ListTile(
                  leading: _fixingYtDlp 
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.build),
                  title: const Text('Fix yt-dlp'),
                ),
              ),
              const PopupMenuItem(
                value: 'test_download',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Test Download'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _checkingPermission 
          ? _buildLoadingScreen()
          : _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Requesting permissions...'),
          SizedBox(height: 8),
          Text('Please allow storage access when prompted', 
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Permission Warning Banner
            if (!_permissionGranted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Storage Permission Required', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Downloads will not work without storage access'),
                          const SizedBox(height: 4),
                          ElevatedButton.icon(
                            onPressed: _requestPermissions,
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Grant Permission'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_backendStatus.contains('❌') || _backendStatus == 'Offline')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Backend Issue: $_backendStatus', style: const TextStyle(color: Colors.red))),
                    TextButton(
                      onPressed: _fixingYtDlp ? null : _fixYtDlp,
                      child: _fixingYtDlp 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('FIX NOW'),
                    ),
                  ],
                ),
              ),

            // Download Path Selection Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Download Location',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getShortPath(_selectedPath),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectingPath ? null : _selectDownloadPath,
                            icon: _selectingPath 
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.folder_open),
                            label: Text(_selectingPath ? 'Selecting...' : 'Change Folder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetToDefaultPath,
                          icon: const Icon(Icons.restore),
                          tooltip: 'Reset to default folder',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Video/Audio URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: 'YouTube, Spotify, SoundCloud, etc...',
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text('Format:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedFormat,
                  items: const [
                    DropdownMenuItem(value: 'best', child: Text('MP4 Video')),
                    DropdownMenuItem(value: 'audio', child: Text('MP3 Audio')),
                  ],
                  onChanged: (value) => setState(() => _selectedFormat = value!),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_analyzing || !_permissionGranted) ? null : _analyzeUrl,
                    icon: const Icon(Icons.search),
                    label: const Text('Analyze URL'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_downloading || _backendStatus.contains('❌') || !_permissionGranted) ? null : _startDownload,
                    icon: _downloading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
                    label: _downloading ? const Text('Downloading...') : const Text('Download'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_analyzing || _downloading)
              LinearProgressIndicator(
                value: _downloading ? null : 0,
                backgroundColor: Colors.grey[300],
              ),

            const SizedBox(height: 16),

            // Dynamic content area with fixed height constraint
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: _buildDynamicContent(),
            ),

            if (_downloadHistory.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Download History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${_downloadHistory.where((item) => item['success'] == true).length} successful',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _downloadHistory.length,
                  itemBuilder: (context, index) {
                    final item = _downloadHistory[index];
                    return ListTile(
                      leading: Icon(
                        item['success'] == true ? Icons.download_done : Icons.error,
                        color: item['success'] == true ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        item['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Format: ${item['format'] == 'audio' ? 'MP3 Audio' : 'MP4 Video'}'),
                          if (item['filename'] != null) Text(
                            'File: ${item['filename']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item['download_path'] != null) Text(
                            'Path: ${_getShortPath(item['download_path'])}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item['method'] != null) Text(
                            'Method: ${item['method']}', 
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item['error'] != null) Text(
                            'Error: ${item['error']}', 
                            style: const TextStyle(color: Colors.red),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        DateTime.parse(item['timestamp']!).toString().split(' ')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    if (_analyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing URL...'),
          ],
        ),
      );
    } else if (_mediaInfo != null) {
      return _buildMediaInfo();
    } else {
      return _buildInstructions();
    }
  }

  Future<void> _testDownload() async {
    _controller.text = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    _addDebugLog('🧪 Starting test download...');
    await _startDownload();
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Logs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Backend: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_backendUrl),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Permissions: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_permissionGranted ? '✅ Granted' : '❌ Denied', 
                    style: TextStyle(color: _permissionGranted ? Colors.green : Colors.red)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Download Path: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      _selectedPath,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: _debugLogs.length,
                    itemBuilder: (context, index) => SelectableText(
                      _debugLogs[index],
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(onPressed: _clearDebugLogs, child: const Text('Clear Logs')),
          TextButton(
            onPressed: _requestPermissions, 
            child: Text(_permissionGranted ? 'Recheck Permissions' : 'Request Permissions')
          ),
          TextButton(
            onPressed: _selectDownloadPath,
            child: const Text('Change Folder')
          ),
        ],
      ),
    );
  }

  Widget _buildMediaInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mediaInfo!['title'] ?? 'Unknown', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('Type: ${_mediaInfo!['type'] == 'playlist' ? 'Playlist' : 'Single Video'}'),
            Text('Videos: ${_mediaInfo!['video_count']}'),
            Text('Platform: ${_mediaInfo!['platform'] ?? 'Unknown'}'),
            Text('Download Format: ${_selectedFormat == 'audio' ? 'MP3 Audio' : 'MP4 Video'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Save to: ${_getShortPath(_selectedPath)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _mediaInfo!['videos']?.length ?? 0,
                itemBuilder: (context, index) {
                  final video = _mediaInfo!['videos'][index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(
                      video['title'] ?? 'Unknown', 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    subtitle: video['duration'] > 0 ? Text('Duration: ${_formatDuration(video['duration'])}') : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _permissionGranted ? Icons.video_library : Icons.warning,
              size: 64, 
              color: _permissionGranted ? Colors.grey : Colors.orange
            ),
            const SizedBox(height: 16),
            Text(
              _permissionGranted 
                  ? 'How to use:\n\n'
                    '1. Paste any video/audio URL\n'
                    '2. Choose download location\n'
                    '3. Click "Analyze URL"\n'
                    '4. Choose format\n'
                    '5. Click "Download"\n\n'
                    '📁 Files save to selected folder\n'
                    '🌐 Supports: YouTube, Spotify, SoundCloud, etc.'
                  : '⚠️ Permission Required\n\n'
                    'Please grant storage permission\n'
                    'to enable downloads.\n\n'
                    'Click the menu button and select\n'
                    '"Grant Permission" or try downloading\n'
                    'to trigger the permission request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _permissionGranted ? Colors.grey : Colors.orange,
                fontWeight: _permissionGranted ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }
}