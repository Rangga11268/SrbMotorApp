import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        showLogo: false,
        title: 'Notifikasi',
        actions: [
          IconButton(
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
            icon: const Icon(Icons.done_all, color: Colors.blue),
            tooltip: 'Tandai semua dibaca',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_outlined, size: 80, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationItem(context, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    final bool isRead = notification.isRead;
    final String timeAgo = _formatTimestamp(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: isRead ? Border.all(color: const Color(0xFFF1F5F9)) : Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: InkWell(
        onTap: () {
          if (!isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
          // Add navigation logic based on notification type if needed
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTitle(notification.type),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.contains('Transaction')) return Icons.shopping_bag_outlined;
    if (type.contains('Credit')) return Icons.verified_user_outlined;
    if (type.contains('Survey')) return Icons.calendar_today_outlined;
    if (type.contains('Installment')) return Icons.payment_outlined;
    return Icons.notifications_outlined;
  }

  Color _getIconColor(String type) {
    if (type.contains('Transaction')) return Colors.blue;
    if (type.contains('Credit')) return Colors.green;
    if (type.contains('Survey')) return Colors.orange;
    if (type.contains('Installment')) return Colors.purple;
    return Colors.grey;
  }

  String _getTitle(String type) {
    if (type.contains('TransactionCreated')) return 'Pesanan Baru';
    if (type.contains('TransactionStatusChanged')) return 'Update Status';
    if (type.contains('SurveyScheduled')) return 'Jadwal Survey';
    if (type.contains('InstallmentReminder')) return 'Tagihan Cicilan';
    return 'Notifikasi';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j yang lalu';
    } else {
      return DateFormat('dd MMM').format(timestamp);
    }
  }
}
