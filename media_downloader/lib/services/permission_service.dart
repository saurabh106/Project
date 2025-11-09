import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PermissionService {
  static Future<bool> requestStoragePermissions() async {
    try {
      var storageStatus = await Permission.storage.status;
      
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      
      var manageStorageStatus = await Permission.manageExternalStorage.status;
      if (!manageStorageStatus.isGranted) {
        manageStorageStatus = await Permission.manageExternalStorage.request();
      }
      
      return storageStatus.isGranted || manageStorageStatus.isGranted;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  static Future<bool> verifyDownloadAccess() async {
    try {
      final directory = await getExternalStorageDirectory();
      final downloadPath = '${directory?.path}/Download';
      final downloadDir = Directory(downloadPath);
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final testFile = File('$downloadPath/.test_write_access');
      await testFile.writeAsString('test', flush: true);
      await testFile.delete();
      
      return true;
    } catch (e) {
      print('Write access denied: $e');
      return false;
    }
  }

  static Future<String> getDefaultDownloadPath() async {
    try {
      final directory = await getExternalStorageDirectory();
      return '${directory?.path}/Download';
    } catch (e) {
      print('Error getting default path: $e');
      return '';
    }
  }
}