import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor.dart';
import '../models/category.dart';
import '../models/leasing_provider.dart';
import 'api_config.dart';

class MotorService {
  Future<List<Motor>> getMotors({String? category, String? brand, String? search}) async {
    final Map<String, String> queryParams = {};
    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (search != null) queryParams['search'] = search;
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/motors').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Motor.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data motor');
    }
  }

  Future<List<String>> getBrands() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/motors/brands'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item.toString()).toList();
    } else {
      throw Exception('Gagal mengambil data merek');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }

  Future<Motor> getMotorDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/motors/$id'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Motor.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail motor');
    }
  }

  Future<List<LeasingProvider>> getLeasingProviders() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leasing-providers'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => LeasingProvider.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data partner pembiayaan');
    }
  }
}
