import 'package:flutter/material.dart';
import '../models/motor.dart';
import '../models/category.dart';
import '../services/motor_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import 'dart:math' as math;

class MotorProvider with ChangeNotifier {
  List<Motor> _allMotors = []; // Data master dari API
  List<CategoryModel> _categories = [];
  List<String> _brands = [];
  String? _contactPhone;

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
  double? _minPrice;
  double? _maxPrice;
  List<Map<String, dynamic>> _branches = [];
  String? _selectedBranch;
  bool _isLocationLoading = false;
  
  bool get isLocationLoading => _isLocationLoading;

  // Getter motors sekarang melakukan filtering lokal (Instant Caching)
  List<Motor> get motors {
    return _allMotors.where((motor) {
      final matchesBrand = _selectedBrand == null || 
          motor.brand.toLowerCase() == _selectedBrand!.toLowerCase();
      
      final matchesCategory = _selectedCategory == null || 
          motor.type == _selectedCategory;

      final matchesSearch = _searchQuery == null || _searchQuery!.isEmpty ||
          motor.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          motor.brand.toLowerCase().contains(_searchQuery!.toLowerCase());

      final matchesMinPrice = _minPrice == null || motor.price >= _minPrice!;
      final matchesMaxPrice = _maxPrice == null || motor.price <= _maxPrice!;

      final matchesBranch = _selectedBranch == null || 
          motor.branch == _selectedBranch;

      return matchesBrand && matchesCategory && matchesSearch && 
             matchesMinPrice && matchesMaxPrice && matchesBranch;
    }).toList();
  }

  List<Motor> get allMotors => _allMotors;

  List<CategoryModel> get categories => _categories;
  List<String> get brands => _brands;
  List<Map<String, dynamic>> get branches => _branches;
  List<Map<String, String>> get leasingProviders => _leasingProviders;
  bool get isLoading => _isLoading || _isCategoriesLoading || _isBrandsLoading;
  bool get isInitialLoading => _isLoading && _allMotors.isEmpty;

  String get contactPhone => _contactPhone ?? '628978638849';
  bool get hasData => _allMotors.isNotEmpty && _brands.isNotEmpty;

  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String? get selectedBrand => _selectedBrand;
  String? get selectedBranch => _selectedBranch;
  String? get searchQuery => _searchQuery;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  final MotorService _motorService = MotorService();

  // Memasukkan semua data ke _allMotors untuk filtering instan
  Future<void> fetchMotors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ambil semua motor tanpa filter API untuk caching lokal
      _allMotors = await _motorService.getMotors();
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

  Future<void> fetchBranches() async {
    try {
      _branches = await _motorService.getBranches();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    }
  }

  Future<void> fetchContactSettings() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/settings/contact');
      final res = await http.get(url, headers: ApiConfig.ngrokHeaders);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final raw = data['contact_phone']?.toString() ?? '';
        final cleaned = raw.replaceAll(RegExp(r'[\s\-\+]'), '');
        if (cleaned.isNotEmpty) {
          _contactPhone = cleaned.startsWith('0') ? '62${cleaned.substring(1)}' : cleaned;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> initializeData() async {
    await Future.wait([
      fetchBrands(), 
      fetchCategories(), 
      fetchContactSettings(),
      fetchBranches(),
    ]);
    await fetchMotors();
  }

  Future<void> initializeIfNeeded() async {
    if (hasData) {
      if (_contactPhone == null) fetchContactSettings();
      if (_branches.isEmpty) fetchBranches();
      return;
    }
    await initializeData();
  }

  // Filter tidak lagi panggil API (Instan)
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setBranch(String? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMinPrice(double? price) {
    _minPrice = price;
    notifyListeners();
  }

  void setMaxPrice(double? price) {
    _maxPrice = price;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = null;
    _selectedBrand = null;
    _searchQuery = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedBranch = null;
    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    // Convert to radians
    double lat1Rad = lat1 * (math.pi / 180.0);
    double lat2Rad = lat2 * (math.pi / 180.0);
    double lonDiffRad = (lon2 - lon1) * (math.pi / 180.0);
    
    // Spherical Law of Cosines (Identical to Web PHP implementation)
    double cosValue = math.cos(lat1Rad) * math.cos(lat2Rad) * math.cos(lonDiffRad) + 
                      math.sin(lat1Rad) * math.sin(lat2Rad);
    
    // Guard against floating point errors that could lead to NaN
    if (cosValue > 1.0) cosValue = 1.0;
    if (cosValue < -1.0) cosValue = -1.0;
    
    return earthRadius * math.acos(cosValue);
  }

  Future<Map<String, dynamic>?> findNearestBranch(double userLat, double userLon, {int? motorId}) async {
    if (_branches.isEmpty) await fetchBranches();
    
    _isLocationLoading = true;
    notifyListeners();
    
    try {
      Map<String, dynamic>? nearestBranch;
      double shortestDistance = double.infinity;

      for (var branch in _branches) {
        final bLat = double.tryParse(branch['latitude']?.toString() ?? '');
        final bLon = double.tryParse(branch['longitude']?.toString() ?? '');
        
        if (bLat == null || bLon == null) continue;

        double distance = calculateDistance(userLat, userLon, bLat, bLon);
        branch['distance'] = distance;

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestBranch = branch;
        }
      }
      
      return nearestBranch;
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  // Find all branches that have a motor with the same name and are in stock
  List<String> getBranchesWithMotor(String motorName) {
    return _allMotors
        .where((m) => m.name.toLowerCase() == motorName.toLowerCase() && m.tersedia == true)
        .map((m) => m.branch?.toString() ?? '')
        .where((b) => b.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
  }
}
