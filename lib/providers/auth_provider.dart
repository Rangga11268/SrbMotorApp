import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final AuthService _authService = AuthService();

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }

    _isLoading = false;
    notifyListeners();
    
    if (!result['success']) {
      throw Exception(result['message']);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    if (result['success']) {
      _user = result['user'];
      _token = result['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }

    _isLoading = false;
    notifyListeners();

    if (!result['success']) {
      throw Exception(result['message']);
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }
}
