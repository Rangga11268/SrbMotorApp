import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, left: 32, right: 32),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 3;
            return Stack(
              children: [
                // Animated Indicator Pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  left: 12 + (itemWidth * selectedIndex),
                  top: 11,
                  child: Container(
                    width: itemWidth,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Indicator Dot/Bar at top or bottom (Optional - let's use a subtle top bar)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutExpo,
                  left: 12 + (itemWidth * selectedIndex) + (itemWidth / 2) - 10,
                  top: 0,
                  child: Container(
                    width: 20,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                // Navigation Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        width: itemWidth,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.assignment_outlined,
                        activeIcon: Icons.assignment_rounded,
                        label: 'Pesanan',
                        width: itemWidth,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                        width: itemWidth,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required double width,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.15 : 1.0,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
