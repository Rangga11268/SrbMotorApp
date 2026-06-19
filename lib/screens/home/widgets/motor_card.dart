import 'package:flutter/material.dart';
import 'package:srb_motor_app/models/motor.dart';

class MotorCard extends StatelessWidget {
  final Motor motor;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  final String Function(double price) formatPrice;

  const MotorCard({
    super.key,
    required this.motor,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _motorImage(height: 110, width: 110),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${motor.brand} • ${motor.type}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onWishlistToggle,
                          icon: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatPrice(motor.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _miniChip('${motor.engineCC} cc'),
                        const SizedBox(width: 8),
                        _miniChip(motor.transmission),
                        const SizedBox(width: 8),
                        _miniChip('${motor.weight} kg'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _motorImage({required double height, required double width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: Image.asset(
          motor.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.two_wheeler, size: 42, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}
