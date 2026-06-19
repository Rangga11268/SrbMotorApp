import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';

class MotorDetailScreen extends StatelessWidget {
  final Motor motor;
  final AppState appState;
  final String Function(double price) formatPrice;

  const MotorDetailScreen({
    super.key,
    required this.motor,
    required this.appState,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = appState.isInWishlist(motor.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Detail Motor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SizedBox(
              height: 260,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        motor.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.two_wheeler, size: 84, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () async {
                          await appState.toggleWishlist(motor.id);
                        },
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${motor.brand} • ${motor.type}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    formatPrice(motor.price),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Deskripsi'),
                  const SizedBox(height: 8),
                  Text(motor.description),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Spesifikasi'),
                  const SizedBox(height: 12),
                  _specRow('Tahun', motor.year.toString()),
                  _specRow('Transmisi', motor.transmission),
                  _specRow('Mesin', '${motor.engineCC} cc'),
                  _specRow('Berat', '${motor.weight} kg'),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Warna'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: motor.colors
                        .map(
                          (color) => Chip(
                            label: Text(color),
                            backgroundColor: const Color(0xFFEFF6FF),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hubungi dealer untuk info lebih lanjut'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'Hubungi Dealer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
