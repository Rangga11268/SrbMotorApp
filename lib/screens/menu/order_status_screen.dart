import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';

class OrderStatusScreen extends StatelessWidget {
  final OrderModel order;
  const OrderStatusScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Status Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: SRB-${order.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              order.motor?.name ?? 'Motor Unit',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 48),
            
            const Text(
              'Timeline Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            _buildTimelineTile(
              title: 'Pesanan Diterima',
              subtitle: dateFormat.format(order.createdAt),
              isFirst: true,
              isCompleted: true,
            ),
            _buildTimelineTile(
              title: 'Menunggu Pembayaran',
              subtitle: order.status == 'pending' ? 'Mohon selesaikan administrasi' : 'Selesai',
              isCompleted: order.status != 'new_order',
            ),
            _buildTimelineTile(
              title: 'Pesanan Selesai',
              subtitle: order.status == 'completed' ? 'Unit telah dikirim/diterima' : 'Menunggu tahap sebelumnya',
              isLast: true,
              isCompleted: order.status == 'completed',
            ),
            
            const SizedBox(height: 48),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(order.customerName),
                    Text(order.customerPhone),
                    Text(order.customerAddress),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
    bool isCompleted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
              child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
