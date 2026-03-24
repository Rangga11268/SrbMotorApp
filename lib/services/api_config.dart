import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Gunakan IP lokal jika menguji di device asli (contoh: 192.168.x.x)
  // Gunakan 10.0.2.2 untuk Android Emulator yang mengakses localhost host
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
