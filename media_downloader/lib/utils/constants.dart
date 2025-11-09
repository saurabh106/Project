import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstants {
  static const String backendUrl = 'http://192.168.0.106:8000';
  
  // Modern color scheme
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06D6A0);
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textColor = Colors.white;
  static const Color hintColor = Color(0xFF94A3B8);
}

class DownloadFormats {
  static const String best = 'best';
  static const String audio = 'audio';
  
  static const List<Map<String, String>> formatOptions = [
    {'value': 'best', 'label': 'MP4 Video'},
    {'value': 'audio', 'label': 'MP3 Audio'},
  ];
}