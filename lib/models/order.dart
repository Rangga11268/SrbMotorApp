import 'motor.dart';

class OrderModel {
  final int id;
  final int userId;
  final int motorId;
  final String customerName;
  final String customerPhone;
  final String customerOccupation;
  final String customerAddress;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final Motor? motor;

  OrderModel({
    required this.id,
    required this.userId,
    required this.motorId,
    required this.customerName,
    required this.customerPhone,
    required this.customerOccupation,
    required this.customerAddress,
    this.notes,
    required this.status,
    required this.createdAt,
    this.motor,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      motorId: json['motor_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerOccupation: json['customer_occupation'],
      customerAddress: json['customer_address'],
      notes: json['notes'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      motor: json['motor'] != null ? Motor.fromJson(json['motor']) : null,
    );
  }
}
