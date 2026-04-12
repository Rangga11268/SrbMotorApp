import 'package:flutter/material.dart';
import '../models/motor.dart';
import '../models/category.dart';
import '../services/motor_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class MotorProvider with ChangeNotifier {
  List<Motor> _motors = [];
  List<CategoryModel> _categories = [];
  List<String> _brands = [];
  String? _contactPhone; // Nomor WA dari DB settings
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

  /// WA number dari DB, fallback ke hardcoded jika belum ter-fetch
  String get contactPhone => _contactPhone ?? '628978638849';

  /// Guard: true jika data utama sudah pernah di-load
  bool get hasData => _motors.isNotEmpty && _brands.isNotEmpty;

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

  /// Fetch nomor WA admin dari tabel settings di DB
  Future<void> fetchContactSettings() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/settings/contact');
      final res = await http.get(url, headers: ApiConfig.ngrokHeaders);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final raw = data['contact_phone']?.toString() ?? '';
        // Normalisasi: hilangkan +, spasi, dash → pastikan awalan 62
        final cleaned = raw.replaceAll(RegExp(r'[\s\-\+]'), '');
        if (cleaned.isNotEmpty) {
          _contactPhone = cleaned.startsWith('0')
              ? '62${cleaned.substring(1)}'
              : cleaned;
          notifyListeners();
        }
      }
    } catch (_) {
      // Gagal fetch → pakai fallback hardcoded
    }
  }

  Future<void> initializeData() async {
    await Future.wait([fetchBrands(), fetchCategories(), fetchContactSettings()]);
    await fetchMotors();
  }

  /// Inisialisasi ringan: skip fetch jika data sudah ada di memori.
  /// Gunakan di initState() agar tidak reload ulang saat back dari screen lain.
  Future<void> initializeIfNeeded() async {
    if (hasData) {
      // Data sudah ada — hanya perbarui WA number jika belum di-fetch
      if (_contactPhone == null) fetchContactSettings();
      return;
    }
    await initializeData();
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
