import 'package:flutter/material.dart';
import '../../models/motor.dart';
import '../order_form/order_form_screen.dart';
import 'package:intl/intl.dart';

class MotorDetailScreen extends StatelessWidget {
  final Motor motor;
  const MotorDetailScreen({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(motor.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder/Header
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: motor.imagePath != null
                    ? DecorationImage(
                        image: NetworkImage(motor.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: motor.imagePath == null
                  ? const Center(child: Icon(Icons.motorcycle, size: 100, color: Colors.grey))
                  : null,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.brand,
                    style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          motor.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        currencyFormat.format(motor.price),
                        style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Spesifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecRow('Engine', '${motor.engine ?? '-'} cc'),
                  _buildSpecRow('Transmission', motor.transmission ?? '-'),
                  _buildSpecRow('Weight', '${motor.weight ?? '-'} kg'),
                  _buildSpecRow('Type', motor.type ?? '-'),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Detail Kendaraan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    motor.details ?? 'Tidak ada detail tersedia untuk produk ini.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderFormScreen(motor: motor),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('PESAN SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
