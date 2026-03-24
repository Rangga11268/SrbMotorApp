import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/order.dart';

class OrderService {
  Future<List<OrderModel>> getOrderHistory() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => OrderModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat pesanan');
    }
  }

  Future<Map<String, dynamic>> placeCashOrder({
    required int motorId,
    required String name,
    required String phone,
    required String occupation,
    required String address,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/cash'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'motor_id': motorId,
        'customer_name': name,
        'customer_phone': phone,
        'customer_occupation': occupation,
        'customer_address': address,
        'notes': notes,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        'success': true,
        'order_id': data['order_id'],
        'message': data['message'] ?? 'Pesanan berhasil dibuat',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat pesanan',
      };
    }
  }
}
