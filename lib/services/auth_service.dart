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
    ).timeout(const Duration(seconds: 10));

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
    ).timeout(const Duration(seconds: 10));

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

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login/google'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'id_token': idToken,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': User.fromJson(data['user']),
        'token': data['token'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal login Google',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': User.fromJson(data['data']),
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil profil',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String nik,
    required String alamat,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'nik': nik,
        'alamat': alamat,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': User.fromJson(data['data']),
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui profil',
      };
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/password'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui password',
      };
    }
  }
}
