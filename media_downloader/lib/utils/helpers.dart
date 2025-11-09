import 'dart:math';

class Helpers {
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  static String getUserFriendlyPath(String fullPath) {
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
    return fullPath;
  }

  static String getFullPathFromUserFriendly(String userFriendlyPath) {
    if (userFriendlyPath.startsWith('Internal Storage')) {
      return '/storage/emulated/0/' + 
          userFriendlyPath.substring('Internal Storage'.length);
    } else if (userFriendlyPath.startsWith('Storage (')) {
      final match = RegExp(r'Storage \(([^)]+)\)(.+)').firstMatch(userFriendlyPath);
      if (match != null) {
        final storageName = match.group(1)!;
        final pathSuffix = match.group(2)!;
        return '/storage/$storageName$pathSuffix';
      }
    }
    return userFriendlyPath;
  }

  static String getShortPath(String fullPath) {
    final userFriendlyPath = getUserFriendlyPath(fullPath);
    if (userFriendlyPath.length > 40) {
      return '...${userFriendlyPath.substring(userFriendlyPath.length - 37)}';
    }
    return userFriendlyPath;
  }
}