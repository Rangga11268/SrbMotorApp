import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Gunakan IP lokal yang sama untuk Web dan App agar sinkron
  static const String baseUrl = 'https://jerrie-lagoonal-cherryl.ngrok-free.dev/api';
  
  static Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...ngrokHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static const Map<String, String> ngrokHeaders = {
    'ngrok-skip-browser-warning': 'true',
  };

  /// Sanitizes URLs by replacing localhost/127.0.0.1 with 10.0.2.2 for Android Emulator.
  /// Also ensures the path format is consistent.
  static String? sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    String sanitized = url;
    
    // Replace local dev hostnames with the host from the current baseUrl
    final uri = Uri.parse(baseUrl);
    final targetHost = uri.host;
    
    sanitized = sanitized.replaceAll(RegExp(r'localhost', caseSensitive: false), targetHost);
    sanitized = sanitized.replaceAll(RegExp(r'127\.0\.0\.1'), targetHost);
    sanitized = sanitized.replaceAll(RegExp(r'10\.0\.2\.2'), targetHost);
    sanitized = sanitized.replaceAll(RegExp(r'srbmotor\.test', caseSensitive: false), targetHost);
    
    // Ensure we don't have double storage/
    if (sanitized.contains('/storage/storage/')) {
       sanitized = sanitized.replaceAll('/storage/storage/', '/storage/');
    }
    
    return sanitized;
  }
}
