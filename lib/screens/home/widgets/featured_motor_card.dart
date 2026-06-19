import 'package:flutter/material.dart';
import 'package:srb_motor_app/models/motor.dart';

class FeaturedMotorCard extends StatelessWidget {
  final Motor motor;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  final String Function(double price) formatPrice;

  const FeaturedMotorCard({
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
      child: SizedBox(
        width: 220,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      motor.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Icon(Icons.two_wheeler, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onWishlistToggle,
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
                    const SizedBox(height: 4),
                    Text(
                      motor.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatPrice(motor.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w800,
                          ),
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
}
