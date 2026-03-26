import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: await ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notificationList = data['data']['data'];
        
        _notifications = notificationList.map((n) => NotificationModel.fromJson(n)).toList();
        _unreadCount = data['unread_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: await ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
          await fetchNotifications();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: await ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        _unreadCount = 0;
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
