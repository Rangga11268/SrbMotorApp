import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': User.fromJson(data['data']),
        'token': data['access_token'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal login',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    print('DEBUG REGISTER RESPONSE: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (data['data'] == null) {
        throw Exception('Server returned success but user data is missing');
      }
      return {
        'success': true,
        'user': User.fromJson(data['data']),
        'token': data['access_token'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal registrasi',
      };
    }
  }
}
