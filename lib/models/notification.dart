class NotificationModel {
  final String id;
  final String type;
  final String message;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map ? json['data'] : {};
    
    return NotificationModel(
      id: json['id'],
      type: json['type'] ?? '',
      message: dataMap['message'] ?? 'Notifikasi baru diterima',
      data: Map<String, dynamic>.from(dataMap),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
