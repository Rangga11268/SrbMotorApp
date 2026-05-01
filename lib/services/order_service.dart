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

  Future<OrderModel> getOrderDetails(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      return OrderModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail pesanan');
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
    String? branch,
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
        'branch': branch,
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

  Future<Map<String, dynamic>> placeCreditOrder({
    required int motorId,
    required String name,
    required String phone,
    required String nik,
    required String address,
    required String motorColor,
    required String deliveryMethod,
    required String paymentMethod,
    required String occupation,
    required double monthlyIncome,
    required String employmentDuration,
    required double dpAmount,
    required int tenor,
    String? branch,
    String? email,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/credit'),
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
        'occupation': occupation,
        'monthly_income': monthlyIncome,
        'employment_duration': employmentDuration,
        'dp_amount': dpAmount,
        'tenor': tenor,
        'branch': branch,
        'notes': notes,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        'success': true,
        'order_id': data['order_id'],
        'message': data['message'] ?? 'Pengajuan kredit berhasil dibuat',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat pengajuan kredit',
      };
    }
  }

  Future<Map<String, dynamic>> getInstallmentPaymentUrl(int installmentId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/installments/$installmentId/pay-online'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'snap_token': data['snap_token'],
        'redirect_url': data['redirection_url'] ?? data['redirect_url'], // Support both naming variants if any
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mendapatkan link pembayaran',
      };
    }
  }

  Future<bool> checkInstallmentStatus(int installmentId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/installments/$installmentId/check-status'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId, String? reason) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/cancel'),
      headers: await ApiConfig.headers,
      body: jsonEncode({'reason': reason}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal membatalkan pesanan'};
    }
  }

  Future<Map<String, dynamic>> getInvoiceUrl(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/get-invoice-url'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'url': data['url']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal mendapatkan link invoice'};
    }
  }
}
