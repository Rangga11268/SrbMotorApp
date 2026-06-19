import 'dart:async';
import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/screens/home/home_screen_new.dart';
import 'package:srb_motor_app/screens/catalog/catalog_screen.dart';
import 'package:srb_motor_app/screens/help/help_faq_screen.dart';
import 'package:srb_motor_app/screens/profile/profile_screen.dart';
import 'package:srb_motor_app/screens/detail/motor_detail_screen.dart';
import 'package:srb_motor_app/screens/detail/motor_detail_phantom_x.dart';

const _surfaceBg = Color(0xFFF5F7FB);

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      bottomNavigationBar: _modernNavBar(),
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            HomeScreenNew(
              appState: widget.appState,
              onTabChange: (index) => setState(() => selectedTab = index),
              onMotorTap: _openDetail,
            ),
            CatalogScreen(
              appState: widget.appState,
              onMotorTap: _openDetail,
            ),
            HelpFaqScreen(
              onTabChange: (index) => setState(() => selectedTab = index),
            ),
            ProfileScreen(
              appState: widget.appState,
              onTabChange: (index) => setState(() => selectedTab = index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _navItem(
                  index: 0,
                  label: 'HOME',
                  iconActive: Icons.home,
                  iconInactive: Icons.home_outlined,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 1,
                  label: 'CATALOG',
                  iconActive: Icons.view_cozy,
                  iconInactive: Icons.view_cozy_outlined,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 2,
                  label: 'HELP',
                  iconActive: Icons.help,
                  iconInactive: Icons.help_outline,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 3,
                  label: 'PROFILE',
                  iconActive: Icons.person,
                  iconInactive: Icons.person_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String label,
    required IconData iconActive,
    required IconData iconInactive,
  }) {
    final active = selectedTab == index;
    final color = active ? const Color(0xFF041627) : const Color(0xFF5F5E5E);
    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? iconActive : iconInactive,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: color,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(Motor motor) async {
    final isPhantomX = motor.id == 99 || motor.name.toLowerCase().contains('phantom');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isPhantomX
            ? MotorDetailPhantomXScreen(appState: widget.appState)
            : MotorDetailScreen(
                motor: motor,
                appState: widget.appState,
                formatPrice: formatPrice,
              ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }
}
