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

// Import refactored files
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/permission_service.dart';
import '../services/backend_service.dart';
import '../services/download_service.dart';
import '../models/download_model.dart';
import '../widgets/custom_card.dart';
import '../widgets/warning_banner.dart';
import '../widgets/media_info_widget.dart';
import '../widgets/instructions_widget.dart';
import '../widgets/download_history.dart';

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
      final downloadPath = await PermissionService.getDefaultDownloadPath();
      setState(() {
        _selectedPath = Helpers.getUserFriendlyPath(downloadPath);
      });
      _addDebugLog('📁 Default download path: $downloadPath');
    } catch (e) {
      _addDebugLog('❌ Error setting default path: $e');
    }
  }

  Future<void> _requestPermissions() async {
    _addDebugLog('🔐 Requesting storage permissions...');
    
    try {
      final granted = await PermissionService.requestStoragePermissions();
      
      if (granted) {
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
      final hasAccess = await PermissionService.verifyDownloadAccess();
      if (hasAccess) {
        _addDebugLog('✅ Write access verified in download directory');
      } else {
        _addDebugLog('❌ Write access denied');
        setState(() {
          _permissionGranted = false;
        });
      }
    } catch (e) {
      _addDebugLog('💥 Access verification error: $e');
      setState(() {
        _permissionGranted = false;
      });
    }
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
            _selectedPath = Helpers.getUserFriendlyPath(selectedDirectory);
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
      final downloadPath = await PermissionService.getDefaultDownloadPath();
      setState(() {
        _selectedPath = Helpers.getUserFriendlyPath(downloadPath);
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
      final data = await BackendService.checkHealth();
      setState(() {
        _backendStatus = data['yt_dlp_status'] ?? 'Unknown';
      });
      _addDebugLog('✅ Backend status: $_backendStatus');
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
      final result = await BackendService.fixYtDlp();
      _addDebugLog('✅ ${result['message']}');
      _showSnackBar(result['message']);
      await _checkBackendStatus();
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
      final data = await BackendService.analyzeUrl(url);
      _addDebugLog('✅ Analysis successful - Type: ${data['type']}, Videos: ${data['video_count']}');
      setState(() {
        _mediaInfo = data;
      });
    } catch (e) {
      _addDebugLog('❌ Analysis failed: $e');
      _showSnackBar('Error: $e');
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
      final fullDownloadPath = Helpers.getFullPathFromUserFriendly(_selectedPath);

      // Make a request to the backend only to let it fetch/process the video
      final downloadUrl = '${AppConstants.backendUrl}/api/download-file?'
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
      final taskId = await DownloadService.downloadWithFlutterDownloader(
        downloadUrl, 
        downloadPath, 
        fileName
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
      final fullDownloadPath = Helpers.getFullPathFromUserFriendly(_selectedPath);
      
      await DownloadService.directDownload(
        url,
        _selectedFormat,
        fullDownloadPath,
        (progress) => _addDebugLog(progress),
        (fileName, filePath) {
          _addDebugLog('✅ Download completed: $filePath');
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
            'method': 'direct_download',
            'success': true,
            'download_path': _selectedPath,
          });
          
          setState(() => _downloading = false);
        },
        (error) {
          _addDebugLog('❌ Download error: $error');
          _showSnackBar('Download failed: $error');
          setState(() => _downloading = false);
        },
      );

    } catch (e) {
      _addDebugLog('💥 Direct download error: $e');
      _showSnackBar('Download error: $e');
      setState(() => _downloading = false);
    }
  }

  Future<void> _checkDownloadPath() async {
    _addDebugLog('📁 Checking download path...');
    try {
      final fullDownloadPath = Helpers.getFullPathFromUserFriendly(_selectedPath);
      final downloadDir = Directory(fullDownloadPath);
      
      _addDebugLog('💾 Current download path: $fullDownloadPath');
      
      if (await downloadDir.exists()) {
        final files = downloadDir.listSync();
        _addDebugLog('📂 Found ${files.length} files in download folder:');
        for (final file in files) {
          if (file is File) {
            final size = await file.length();
            _addDebugLog('   - ${file.path.split('/').last} (${Helpers.formatFileSize(size)})');
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
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _testDownload() async {
    _controller.text = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    _addDebugLog('🧪 Starting test download...');
    await _startDownload();
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Debug Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
              const SizedBox(height: 16),
              Container(
                width: double.maxFinite,
                height: 300,
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  itemCount: _debugLogs.length,
                  itemBuilder: (context, index) => SelectableText(
                    _debugLogs[index],
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearDebugLogs,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.textColor,
                        side: BorderSide(color: AppConstants.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Clear Logs'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: AppConstants.textColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Section
            _buildMenuSection(
              icon: Icons.health_and_safety,
              title: 'Backend Status',
              subtitle: _backendStatus,
              color: _backendStatus.contains('✅') ? AppConstants.accentColor : Colors.orange,
              onTap: _checkBackendStatus,
            ),
            
            // Permission Section
            _buildMenuSection(
              icon: Icons.security,
              title: 'Permissions',
              subtitle: _permissionGranted ? 'Granted' : 'Required',
              color: _permissionGranted ? AppConstants.accentColor : Colors.orange,
              onTap: _requestPermissions,
            ),
            
            // Download Location
            _buildMenuSection(
              icon: Icons.folder_open,
              title: 'Download Location',
              subtitle: Helpers.getShortPath(_selectedPath),
              color: AppConstants.primaryColor,
              onTap: _selectDownloadPath,
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMenuButton(
                  icon: Icons.bug_report,
                  label: 'Debug Logs',
                  onTap: () {
                    Navigator.pop(context);
                    _showDebugDialog();
                  },
                ),
                _buildMenuButton(
                  icon: Icons.clear_all,
                  label: 'Clear Logs',
                  onTap: () {
                    Navigator.pop(context);
                    _clearDebugLogs();
                  },
                ),
                _buildMenuButton(
                  icon: Icons.build,
                  label: 'Fix yt-dlp',
                  onTap: () {
                    Navigator.pop(context);
                    _fixYtDlp();
                  },
                ),
                _buildMenuButton(
                  icon: Icons.folder_special,
                  label: 'Check Path',
                  onTap: () {
                    Navigator.pop(context);
                    _checkDownloadPath();
                  },
                ),
                _buildMenuButton(
                  icon: Icons.play_arrow,
                  label: 'Test Download',
                  onTap: () {
                    Navigator.pop(context);
                    _testDownload();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.textColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: AppConstants.hintColor)),
      trailing: Icon(Icons.chevron_right, color: AppConstants.hintColor),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppConstants.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.downloading, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Media Downloader',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppConstants.cardColor,
              color: AppConstants.accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Requesting permissions...',
            style: TextStyle(color: AppConstants.hintColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Please allow storage access when prompted', 
            style: TextStyle(fontSize: 12, color: AppConstants.hintColor),
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
              WarningBanner(
                icon: Icons.warning_amber_rounded,
                title: 'Storage Permission Required',
                message: 'Downloads will not work without storage access',
                actionText: 'Grant Permission',
                onAction: _requestPermissions,
                color: Colors.orange,
              ),

            // Backend Status Banner
            if (_backendStatus.contains('❌') || _backendStatus == 'Offline')
              WarningBanner(
                icon: Icons.error_outline_rounded,
                title: 'Backend Issue',
                message: _backendStatus,
                actionText: 'FIX NOW',
                onAction: _fixingYtDlp ? null : _fixYtDlp,
                color: Colors.red,
                isLoading: _fixingYtDlp,
              ),

            const SizedBox(height: 16),

            // Download Path Selection Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.folder_rounded, color: AppConstants.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Download Location',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppConstants.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Helpers.getShortPath(_selectedPath),
                            style: TextStyle(fontSize: 14, color: AppConstants.hintColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectingPath ? null : _selectDownloadPath,
                          icon: _selectingPath 
                              ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.textColor)) 
                              : Icon(Icons.folder_open_rounded, size: 20),
                          label: Text(_selectingPath ? 'Selecting...' : 'Change Folder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: AppConstants.textColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _resetToDefaultPath,
                        icon: Icon(Icons.restore_rounded, color: AppConstants.primaryColor),
                        style: IconButton.styleFrom(
                          backgroundColor: AppConstants.backgroundColor,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // URL Input Section
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Media URL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textColor),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: AppConstants.textColor),
                    decoration: InputDecoration(
                      hintText: 'YouTube, Spotify, SoundCloud, etc...',
                      hintStyle: TextStyle(color: AppConstants.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      prefixIcon: Icon(Icons.link_rounded, color: AppConstants.primaryColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Format:', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.textColor)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFormat,
                          dropdownColor: AppConstants.cardColor,
                          style: TextStyle(color: AppConstants.textColor),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'best', child: Text('MP4 Video')),
                            DropdownMenuItem(value: 'audio', child: Text('MP3 Audio')),
                          ],
                          onChanged: (value) => setState(() => _selectedFormat = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_analyzing || !_permissionGranted) ? null : _analyzeUrl,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Analyze URL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.backgroundColor,
                      foregroundColor: AppConstants.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppConstants.primaryColor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_downloading || _backendStatus.contains('❌') || !_permissionGranted) ? null : _startDownload,
                    icon: _downloading 
                        ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.textColor)) 
                        : Icon(Icons.download_rounded),
                    label: _downloading ? const Text('Downloading...') : const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: AppConstants.textColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Indicator
            if (_analyzing || _downloading)
              CustomCard(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _analyzing ? null : 0,
                      backgroundColor: AppConstants.backgroundColor,
                      color: AppConstants.accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analyzing ? 'Analyzing URL...' : 'Downloading...',
                      style: TextStyle(fontSize: 12, color: AppConstants.hintColor),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Dynamic content area with fixed height constraint
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: _buildDynamicContent(),
            ),

            // Download History
            if (_downloadHistory.isNotEmpty) ...[
              const SizedBox(height: 20),
              DownloadHistory(downloadHistory: _downloadHistory),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    if (_analyzing) {
      return CustomCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppConstants.primaryColor,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Analyzing URL...', style: TextStyle(color: AppConstants.textColor)),
            const SizedBox(height: 8),
            Text('Please wait while we fetch media information', 
              style: TextStyle(color: AppConstants.hintColor, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (_mediaInfo != null) {
      return MediaInfoWidget(
        mediaInfo: _mediaInfo!,
        selectedFormat: _selectedFormat,
        selectedPath: _selectedPath,
      );
    } else {
      return InstructionsWidget(permissionGranted: _permissionGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Media Downloader', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.cardColor,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showAppMenu(context),
          ),
        ],
      ),
      body: _checkingPermission 
          ? _buildLoadingScreen()
          : _buildMainContent(),
    );
  }
}