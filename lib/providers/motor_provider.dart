import 'package:flutter/material.dart';
import '../models/motor.dart';
import '../models/category.dart';
import '../models/leasing_provider.dart';
import '../services/motor_service.dart';

class MotorProvider with ChangeNotifier {
  List<Motor> _motors = [];
  List<CategoryModel> _categories = [];
  List<LeasingProvider> _leasingProviders = [];
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String? _searchQuery;

  List<Motor> get motors => _motors;
  List<CategoryModel> get categories => _categories;
  List<LeasingProvider> get leasingProviders => _leasingProviders;
  bool get isLoading => _isLoading || _isCategoriesLoading;
  bool get isInitialLoading => _isLoading && _motors.isEmpty;
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

  Future<void> fetchCategories() async {
    _isCategoriesLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _motorService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeData() async {
    await fetchCategories();
    await fetchMotors();
    fetchLeasingProviders(); // fire-and-forget, not critical for initial load
  }

  Future<void> fetchLeasingProviders() async {
    try {
      _leasingProviders = await _motorService.getLeasingProviders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching leasing providers: $e');
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
