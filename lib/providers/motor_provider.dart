import 'package:flutter/material.dart';
import '../models/motor.dart';
import '../models/category.dart';
import '../services/motor_service.dart';

class MotorProvider with ChangeNotifier {
  List<Motor> _motors = [];
  List<CategoryModel> _categories = [];
  List<String> _brands = [];
  final List<Map<String, String>> _leasingProviders = [
    {"name": "ADIRA Finance", "logoUrl": "assets/images/logos/adira.webp"},
    {"name": "FIF Group", "logoUrl": "assets/images/logos/fif.webp"},
    {"name": "OTO Finance", "logoUrl": "assets/images/logos/oto.webp"},
    {"name": "MUF Mandiri", "logoUrl": "assets/images/logos/muf.webp"},
    {"name": "BAF", "logoUrl": "assets/images/logos/baf.webp"},
  ];
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  bool _isBrandsLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String? _selectedBrand;
  String? _searchQuery;

  List<Motor> get motors => _motors;
  List<CategoryModel> get categories => _categories;
  List<String> get brands => _brands;
  List<Map<String, String>> get leasingProviders => _leasingProviders;
  bool get isLoading => _isLoading || _isCategoriesLoading || _isBrandsLoading;
  bool get isInitialLoading => _isLoading && _motors.isEmpty;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String? get selectedBrand => _selectedBrand;

  final MotorService _motorService = MotorService();

  Future<void> fetchMotors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _motors = await _motorService.getMotors(
        category: _selectedCategory,
        brand: _selectedBrand,
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

  Future<void> fetchBrands() async {
    _isBrandsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _brands = await _motorService.getBrands();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isBrandsLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeData() async {
    await Future.wait([fetchBrands(), fetchCategories()]);
    await fetchMotors();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    fetchMotors();
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    fetchMotors();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchMotors();
  }
}
