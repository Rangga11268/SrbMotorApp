import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor.dart';
import 'api_config.dart';

class MotorService {
  Future<List<Motor>> getMotors({String? category, String? search}) async {
    final queryParams = {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
    };
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/motors').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Motor.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data motor');
    }
  }

  Future<Motor> getMotorDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/motors/$id'),
      headers: await ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Motor.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail motor');
    }
  }
}
