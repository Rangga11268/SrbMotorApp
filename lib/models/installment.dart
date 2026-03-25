class InstallmentModel {
  final int id;
  final int transactionId;
  final int installmentNumber;
  final double amount;
  final double penaltyAmount;
  final DateTime? dueDate;
  final String status;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? snapToken;
  final String? midtransBookingCode;

  InstallmentModel({
    required this.id,
    required this.transactionId,
    required this.installmentNumber,
    required this.amount,
    required this.penaltyAmount,
    this.dueDate,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    this.snapToken,
    this.midtransBookingCode,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      installmentNumber: json['installment_number'] ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      penaltyAmount: double.tryParse(json['penalty_amount'].toString()) ?? 0.0,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      paymentMethod: json['payment_method'],
      snapToken: json['snap_token'],
      midtransBookingCode: json['midtrans_booking_code'],
    );
  }
}
