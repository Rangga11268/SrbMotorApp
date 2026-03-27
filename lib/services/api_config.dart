import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Gunakan IP lokal yang sama untuk Web dan App agar sinkron
  static const String baseUrl = 'http://192.168.1.9:8000/api';
  
  static Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Sanitizes URLs by replacing localhost/127.0.0.1 with 10.0.2.2 for Android Emulator.
  /// Also ensures the path format is consistent.
  static String? sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    String sanitized = url;
    
    // Case-insensitive replacement for various local dev hostnames to the unified IP
    sanitized = sanitized.replaceAll(RegExp(r'localhost', caseSensitive: false), '192.168.1.9');
    sanitized = sanitized.replaceAll(RegExp(r'127\.0\.0\.1'), '192.168.1.9');
    sanitized = sanitized.replaceAll(RegExp(r'10\.0\.2\.2'), '192.168.1.9');
    sanitized = sanitized.replaceAll(RegExp(r'srbmotor\.test', caseSensitive: false), '192.168.1.9');
    
    // Ensure we don't have double storage/
    if (sanitized.contains('/storage/storage/')) {
       sanitized = sanitized.replaceAll('/storage/storage/', '/storage/');
    }
    
    return sanitized;
  }
}
