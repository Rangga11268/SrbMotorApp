import 'package:flutter/material.dart';
import 'dart:async';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _lastOrderResult;
  Timer? _pollingTimer;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get lastOrderResult => _lastOrderResult;

  final OrderService _orderService = OrderService();

  Future<void> fetchOrderHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrderHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitCashOrder({
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
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _orderService.placeCashOrder(
        motorId: motorId,
        name: name,
        phone: phone,
        nik: nik,
        address: address,
        motorColor: motorColor,
        deliveryMethod: deliveryMethod,
        paymentMethod: paymentMethod,
        bookingFee: bookingFee,
        email: email,
        notes: notes,
      );

      if (result['success']) {
        _successMessage = result['message'];
        _lastOrderResult = result;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getInstallmentPaymentUrl(int installmentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _orderService.getInstallmentPaymentUrl(installmentId);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshOrderStatus(int installmentId) async {
    return await _orderService.checkInstallmentStatus(installmentId);
  }

  Future<void> syncOrderDetails(OrderModel order) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Sync each pending/unpaid installment with Midtrans
      for (var inst in order.installments) {
        if (inst.status.toLowerCase() != 'paid') {
          await _orderService.checkInstallmentStatus(inst.id);
        }
      }
      // Reload final state from DB
      await fetchOrderHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId, String? reason) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _orderService.cancelOrder(orderId, reason);
      if (result['success']) {
        await fetchOrderHistory();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getInvoiceUrl(int orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _orderService.getInvoiceUrl(orderId);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start background polling for a specific installment status
  void startPollingStatus(int installmentId) {
    // 1. Stop any existing timer first
    stopPollingStatus();

    debugPrint('Starting background polling for installment $installmentId');
    
    // 2. Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint('Polling status for $installmentId...');
      
      final isPaid = await _orderService.checkInstallmentStatus(installmentId);
      
      if (isPaid) {
        debugPrint('Payment detected as PAID in background! Refreshing history...');
        timer.cancel();
        _pollingTimer = null;
        
        // Refresh full history to update all UI parts
        await fetchOrderHistory();
      }
    });

    // 3. Auto-stop after 5 minutes to save resources if user leaves it forever
    Timer(const Duration(minutes: 5), () {
      if (_pollingTimer != null) {
        debugPrint('Auto-stopping polling after timeout');
        stopPollingStatus();
      }
    });
  }

  /// Explicitly stop status polling
  void stopPollingStatus() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
      debugPrint('Polling status stopped manually.');
    }
  }

  @override
  void dispose() {
    stopPollingStatus();
    super.dispose();
  }
}
