import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  User? _currentUser;
  List<int> _wishlist = [];
  bool _isInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<int> get wishlist => _wishlist;
  bool get isInitialized => _isInitialized;

  // Initialize SharedPreferences and load saved data
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadWishlist();
    _checkExistingUser();
    _isInitialized = true;
    notifyListeners();
  }

  // Load wishlist from SharedPreferences
  void _loadWishlist() {
    final wishlistJson = _prefs.getStringList('wishlist') ?? [];
    _wishlist = wishlistJson.map((id) => int.parse(id)).toList();
  }

  // Check if user was previously logged in
  void _checkExistingUser() {
    final userId = _prefs.getString('userId');
    final userName = _prefs.getString('userName');
    final userEmail = _prefs.getString('userEmail');
    final userPhone = _prefs.getString('userPhone');

    if (userId != null && userName != null && userEmail != null && userPhone != null) {
      _currentUser = User(
        id: userId,
        name: userName,
        email: userEmail,
        phone: userPhone,
      );
    }
  }

  // Simple login with email and password
  Future<bool> login(String email, String password) async {
    // Simple validation - in real app, would verify against backend
    if (email.contains('@') && password.length >= 6) {
      // Generate simple user ID
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      _currentUser = User(
        id: userId,
        name: email.split('@')[0], // Use email prefix as name
        email: email,
        phone: '08xx-xxxx-xxxx',
      );

      // Save to SharedPreferences
      await _prefs.setString('userId', userId);
      await _prefs.setString('userName', _currentUser!.name);
      await _prefs.setString('userEmail', _currentUser!.email);
      await _prefs.setString('userPhone', _currentUser!.phone);

      notifyListeners();
      return true;
    }
    return false;
  }

  // Simple registration
  Future<bool> register(String email, String name, String phone, String password) async {
    if (email.contains('@') && password.length >= 6 && name.isNotEmpty && phone.isNotEmpty) {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        phone: phone,
      );

      // Save to SharedPreferences
      await _prefs.setString('userId', userId);
      await _prefs.setString('userName', name);
      await _prefs.setString('userEmail', email);
      await _prefs.setString('userPhone', phone);

      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove('userId');
    await _prefs.remove('userName');
    await _prefs.remove('userEmail');
    await _prefs.remove('userPhone');
    notifyListeners();
  }

  // Toggle wishlist item
  Future<void> toggleWishlist(int motorId) async {
    if (_wishlist.contains(motorId)) {
      _wishlist.remove(motorId);
    } else {
      _wishlist.add(motorId);
    }
    
    // Save to SharedPreferences
    await _prefs.setStringList('wishlist', _wishlist.map((id) => id.toString()).toList());
    notifyListeners();
  }

  // Check if motor is in wishlist
  bool isInWishlist(int motorId) {
    return _wishlist.contains(motorId);
  }

  // Clear all wishlist
  Future<void> clearWishlist() async {
    _wishlist.clear();
    await _prefs.remove('wishlist');
    notifyListeners();
  }
}
