import 'dart:async';
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

  Future<Map<String, dynamic>> getServicePaymentToken(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _service.getPaymentToken(id);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncServiceHistory() async {
    await fetchHistory();
  }

  Timer? _servicePollingTimer;
  int? _activePollingServiceId;

  void startPollingServiceStatus(int appointmentId) {
    stopPollingServiceStatus();
    _activePollingServiceId = appointmentId;

    _servicePollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final isPaid = await _service.checkPaymentStatus(appointmentId);
      if (isPaid) {
        timer.cancel();
        _servicePollingTimer = null;
        await fetchHistory();
      }
    });

    Timer(const Duration(minutes: 5), () => stopPollingServiceStatus());
  }

  void stopPollingServiceStatus() {
    _servicePollingTimer?.cancel();
    _servicePollingTimer = null;
    _activePollingServiceId = null;
  }

  Future<void> syncActiveServicePayment() async {
    if (_activePollingServiceId != null) {
      final isPaid = await _service.checkPaymentStatus(_activePollingServiceId!);
      if (isPaid) stopPollingServiceStatus();
      await fetchHistory();
    }
  }

  @override
  void dispose() {
    stopPollingServiceStatus();
    super.dispose();
  }
}
