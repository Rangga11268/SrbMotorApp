import 'motor.dart';
import 'installment.dart';

class OrderModel {
  final int id;
  final int userId;
  final int motorId;
  final String customerName;
  final String customerPhone;
  final String? customerNik;
  final String? customerEmail;
  final String customerAddress;
  final String? customerOccupation;
  final String? motorColor;
  final String? deliveryMethod;
  final String? paymentMethod;
  final double bookingFee;
  final String? notes;
  final String status;
  final String statusText;
  final String? transactionType;
  final String? branchCode;
  final DateTime createdAt;
  final Motor? motor;
  final List<InstallmentModel> installments;

  OrderModel({
    required this.id,
    required this.userId,
    required this.motorId,
    required this.customerName,
    required this.customerPhone,
    this.customerNik,
    this.customerEmail,
    required this.customerAddress,
    this.customerOccupation,
    this.motorColor,
    this.deliveryMethod,
    this.paymentMethod,
    this.bookingFee = 0.0,
    this.notes,
    required this.status,
    required this.statusText,
    this.transactionType,
    this.branchCode,
    required this.createdAt,
    this.motor,
    this.installments = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var installmentList = json['installments'] as List?;
    List<InstallmentModel> items = installmentList != null
        ? installmentList.map((i) => InstallmentModel.fromJson(i)).toList()
        : [];

    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      motorId: json['motor_id'],
      customerName: json['name'] ?? json['customer_name'],
      customerPhone: json['phone'] ?? json['customer_phone'],
      customerNik: json['nik'] ?? json['customer_nik'],
      customerEmail: json['email'] ?? json['customer_email'],
      customerAddress: json['address'] ?? json['customer_address'],
      customerOccupation: json['occupation'] ?? json['customer_occupation'],
      motorColor: json['motor_color'],
      deliveryMethod: json['delivery_method'],
      paymentMethod: json['payment_method'],
      bookingFee: double.tryParse(json['booking_fee'].toString()) ?? 0.0,
      notes: json['notes'],
      status: json['status'],
      statusText: json['status_text'] ?? (json['status'] ?? 'Unknown').toString().replaceAll('_', ' ').toUpperCase(),
      transactionType: json['transaction_type'],
      branchCode: json['branch_code'] ?? json['branch'],
      createdAt: DateTime.parse(json['created_at']),
      motor: json['motor'] != null ? Motor.fromJson(json['motor']) : null,
      installments: items,
    );
  }
}
