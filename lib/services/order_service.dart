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
    required String nik,
    required String address,
    required String motorColor,
    required String deliveryMethod,
    required String paymentMethod,
    double? bookingFee,
    String? email,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/cash'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'motor_id': motorId,
        'customer_name': name,
        'customer_phone': phone,
        'customer_email': email,
        'customer_nik': nik,
        'customer_address': address,
        'motor_color': motorColor,
        'delivery_method': deliveryMethod,
        'payment_method': paymentMethod,
        'booking_fee': bookingFee,
        'notes': notes,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        'success': true,
        'order_id': data['order_id'],
        'snap_token': data['snap_token'],
        'redirect_url': data['redirect_url'],
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
