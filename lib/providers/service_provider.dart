import 'package:flutter/material.dart';
import '../services/service_booking_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceBookingService _service = ServiceBookingService();

  List<dynamic> _history = [];
  List<dynamic> _availableSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get history => _history;
  List<dynamic> get availableSlots => _availableSlots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _service.getServiceHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSlots(String date, String branch) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSlots = await _service.getAvailableSlots(date, branch);
    } catch (e) {
      _errorMessage = e.toString();
      _availableSlots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookService({
    required String branch,
    required String plateNumber,
    required String serviceDate,
    required String serviceTime,
    String? motorModel,
    String? serviceType,
    String? complaintNotes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.bookService(
        branch: branch,
        plateNumber: plateNumber,
        serviceDate: serviceDate,
        serviceTime: serviceTime,
        motorModel: motorModel,
        serviceType: serviceType,
        complaintNotes: complaintNotes,
      );

      if (result['success']) {
        await fetchHistory();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(int id, String? reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.cancelService(id, reason);
      if (result['success']) {
        await fetchHistory();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
