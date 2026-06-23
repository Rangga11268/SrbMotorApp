import 'package:flutter/material.dart';
import 'package:srb_motor_app/models/motor.dart';

class MotorCompareScreen extends StatelessWidget {
  final Motor motor1;
  final Motor motor2;
  final String Function(double price) formatPrice;

  const MotorCompareScreen({
    super.key,
    required this.motor1,
    required this.motor2,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF041627)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Perbandingan Motor',
          style: TextStyle(color: Color(0xFF041627), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header side-by-side comparison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: _buildHeaderColumn(motor1)),
                  Container(
                    width: 1,
                    height: 120,
                    color: const Color(0xFFE2E2E2),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(child: _buildHeaderColumn(motor2)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Comparison Table Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perbandingan Spesifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF041627),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _compareRow('Harga', formatPrice(motor1.price), formatPrice(motor2.price), isPrimary: true),
                  _compareRow('Merek', motor1.brand, motor2.brand),
                  _compareRow('Tipe', motor1.type, motor2.type),
                  _compareRow('Kapasitas Mesin', '${motor1.engineCC} cc', '${motor2.engineCC} cc'),
                  _compareRow('Transmisi', motor1.transmission, motor2.transmission),
                  _compareRow('Berat', '${motor1.weight} kg', '${motor2.weight} kg'),
                  _compareRow('Tahun Rilis', motor1.year.toString(), motor2.year.toString()),
                  _compareRow('Pilihan Warna', motor1.colors.join(', '), motor2.colors.join(', ')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(Motor motor) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Image.asset(
            motor.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 48, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          motor.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF041627),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          motor.brand,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _compareRow(String label, String val1, String val2, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  val1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                    color: isPrimary ? const Color(0xFF2563EB) : const Color(0xFF041627),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  val2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                    color: isPrimary ? const Color(0xFF2563EB) : const Color(0xFF041627),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}
