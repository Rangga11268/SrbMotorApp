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

  /// Guard: true jika data sudah pernah di-load
  bool get hasData => _orders.isNotEmpty;

  /// Inisialisasi ringan: skip fetch jika data sudah ada di memori.
  /// Gunakan di initState() halaman riwayat pesanan.
  Future<void> initializeIfNeeded() async {
    if (hasData) return;
    await fetchOrderHistory();
  }

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
    required dynamic ktpImage,
    required dynamic kkImage,
    String? branch,
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
        ktpImage: ktpImage,
        kkImage: kkImage,
        branch: branch,
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

  Future<bool> submitCreditOrder({
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
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _orderService.placeCreditOrder(
        motorId: motorId,
        name: name,
        phone: phone,
        nik: nik,
        address: address,
        motorColor: motorColor,
        deliveryMethod: deliveryMethod,
        paymentMethod: paymentMethod,
        occupation: occupation,
        monthlyIncome: monthlyIncome,
        employmentDuration: employmentDuration,
        dpAmount: dpAmount,
        tenor: tenor,
        branch: branch,
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

  /// Syncs a single order and updates the local list to trigger UI rebuilds
  Future<void> syncSingleOrder(int orderId) async {
    try {
      final updatedOrder = await _orderService.getOrderDetails(orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners(); // This will trigger Specific Selectors immediately
      }
    } catch (e) {
      debugPrint('Error syncing single order: $e');
    }
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
      // Reload this specific order only for speed, then reload history in background
      await syncSingleOrder(order.id);
      fetchOrderHistory(); // Background full refresh
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

  int? _activePollingInstallmentId;
  int? _activePollingOrderId;

  /// Start background polling for a specific installment status
  void startPollingStatus(int installmentId, int orderId) {
    // 1. Stop any existing timer first
    stopPollingStatus();
    
    _activePollingInstallmentId = installmentId;
    _activePollingOrderId = orderId;

    debugPrint('Starting background polling for installment $installmentId (Order: $orderId)');
    
    // 2. Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint('Polling status for $installmentId...');
      
      final isPaid = await _orderService.checkInstallmentStatus(installmentId);
      
      if (isPaid) {
        debugPrint('Payment detected as PAID in background! Syncing order $orderId...');
        timer.cancel();
        _pollingTimer = null;
        
        // Refresh this single order for instant UI update
        await syncSingleOrder(orderId);
        
        // Background full refresh
        fetchOrderHistory();
      }
    });

    // 3. Auto-stop after 5 minutes
    Timer(const Duration(minutes: 5), () {
      if (_pollingTimer != null) {
        debugPrint('Auto-stopping polling after timeout');
        stopPollingStatus();
      }
    });
  }

  /// Force a sync immediately (useful when returning from native SDK)
  Future<void> syncActivePayment() async {
    if (_activePollingInstallmentId != null && _activePollingOrderId != null) {
      debugPrint('Forcing instant sync for active payment: $_activePollingInstallmentId');
      
      _isLoading = true;
      notifyListeners();
      
      try {
        final isPaid = await _orderService.checkInstallmentStatus(_activePollingInstallmentId!);
        await syncSingleOrder(_activePollingOrderId!);
        if (isPaid) {
          stopPollingStatus(); // Payment complete, no need to poll anymore
        }
        await fetchOrderHistory();
      } catch (e) {
        debugPrint('Error syncing active payment: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Fallback
      await fetchOrderHistory();
    }
  }

  /// Explicitly stop status polling
  void stopPollingStatus() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
      debugPrint('Polling status stopped manually.');
    }
    _activePollingInstallmentId = null;
    _activePollingOrderId = null;
  }

  @override
  void dispose() {
    stopPollingStatus();
    super.dispose();
  }
}
