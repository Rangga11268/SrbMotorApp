import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ServiceBookingService {
  Future<List<dynamic>> getServiceHistory() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/services'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil riwayat servis');
    }
  }

  Future<List<dynamic>> getAvailableSlots(String date, String branch) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/services/available-slots?date=$date&branch=$branch'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['slots'] ?? [];
    } else {
      throw Exception('Gagal mengambil slot waktu');
    }
  }

  Future<Map<String, dynamic>> bookService({
    required String branch,
    required String plateNumber,
    required String serviceDate,
    required String serviceTime,
    String? motorModel,
    String? serviceType,
    String? complaintNotes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/services/book'),
      headers: await ApiConfig.headers,
      body: jsonEncode({
        'branch': branch,
        'plate_number': plateNumber,
        'service_date': serviceDate,
        'service_time': serviceTime,
        'motor_model': motorModel,
        'service_type': serviceType,
        'complaint_notes': complaintNotes,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'] ?? 'Berhasil memesan servis',
        'appointment': data['appointment'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memesan servis',
      };
    }
  }

  Future<Map<String, dynamic>> cancelService(int id, String? reason) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/services/$id/cancel'),
      headers: await ApiConfig.headers,
      body: jsonEncode({'reason': reason}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal membatalkan servis'};
    }
  }

  Future<Map<String, dynamic>> getPaymentToken(int appointmentId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/services/$appointmentId/pay'),
      headers: await ApiConfig.headers,
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'snap_token': data['token'],
      };
    } else {
      return {
        'success': false,
        'message': data['error'] ?? 'Gagal mendapatkan token pembayaran',
      };
    }
  }
}
