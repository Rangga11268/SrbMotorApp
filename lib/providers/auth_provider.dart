import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = result['user'];
        _token = result['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
      }

      if (!result['success']) {
        throw Exception(result['message']);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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

    try {
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

      if (!result['success']) {
        throw Exception(result['message']);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ID Token not found from Google.');
      }

      final result = await _authService.loginWithGoogle(idToken);

      if (result['success']) {
        _user = result['user'];
        _token = result['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      _user = null;
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      _token = token;
      _isLoading = true;
      notifyListeners();

      try {
        final result = await _authService.getUserProfile();
        if (result['success']) {
          _user = result['user'];
        } else {
          // Token mungkin expired
          _token = null;
          await prefs.remove('token');
        }
      } catch (e) {
        debugPrint('CheckAuth Error: $e');
        // Tetap simpan token tapi user null jika hanya masalah koneksi?
        // Untuk amannya, jika gagal total (kecuali timeout), biarkan user login ulang
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String nik,
    required String alamat,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
        nik: nik,
        alamat: alamat,
      );

      if (result['success']) {
        _user = result['user'];
      } else {
        throw Exception(result['message']);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
