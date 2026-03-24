import 'package:flutter/material.dart';
import '../models/motor.dart';
import '../services/motor_service.dart';

class MotorProvider with ChangeNotifier {
  List<Motor> _motors = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String? _searchQuery;

  List<Motor> get motors => _motors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  final MotorService _motorService = MotorService();

  Future<void> fetchMotors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _motors = await _motorService.getMotors(
        category: _selectedCategory,
        search: _searchQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    fetchMotors();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMotors();
  }
}
