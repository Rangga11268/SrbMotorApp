import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/models/user.dart';
import 'package:srb_motor_app/screens/home/widgets/motor_card.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  final Function(int) onTabChange;

  const ProfileScreen({
    super.key,
    required this.appState,
    required this.onTabChange,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.appState.currentUser;
    nameController = TextEditingController(text: user?.name ?? 'Budi');
    phoneController = TextEditingController(text: user?.phone ?? '+62 812 3456 7890');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      isSaving = true;
    });

    // Simulate saving changes
    await Future.delayed(const Duration(milliseconds: 800));

    final user = widget.appState.currentUser;
    if (user != null) {
      // Create new user with updated data
      final updatedUser = User(
        id: user.id,
        email: user.email,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      debugPrint('Updated user: ${updatedUser.name}');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan!')),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  List<Motor> get savedMotors {
    return motorList.where((motor) => widget.appState.isInWishlist(motor.id)).toList();
  }

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // bg-background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Color(0xFF041627), fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF041627)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Belum ada notifikasi')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Image Avatar Placeholder
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFD2E4FB),
                  child: Text(
                    nameController.text.isNotEmpty
                        ? nameController.text[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF041627),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'budi@example.com',
                  style: const TextStyle(color: Color(0xFF5F5E5E), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Form Edit Profile
          const Text(
            'DATA PROFIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF041627),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE2E2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Nama Panggilan
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'NAMA PANGGILAN',
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5F5E5E),
                        letterSpacing: 1.0,
                      ),
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE2E2E2)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16, color: Color(0xFF041627), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  // Nomor WhatsApp
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'NOMOR WHATSAPP',
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5F5E5E),
                        letterSpacing: 1.0,
                      ),
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE2E2E2)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16, color: Color(0xFF041627), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Save Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF041627),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
          // Saved Motorcycles Section
          const Text(
            'MOTOR TERSIMPAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF041627),
            ),
          ),
          const SizedBox(height: 16),
          if (savedMotors.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: const Text(
                'Belum ada motor yang disimpan.',
                style: TextStyle(color: Color(0xFF5F5E5E)),
              ),
            )
          else
            Column(
              children: savedMotors.map((motor) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MotorCard(
                    motor: motor,
                    isWishlisted: true,
                    onWishlistToggle: () async {
                      await widget.appState.toggleWishlist(motor.id);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onTap: () {
                      Navigator.pushNamed(context, '/detail_phantom_x');
                    },
                    formatPrice: formatPrice,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          // Logout Button
          OutlinedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await widget.appState.logout();
              navigator.pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
            label: const Text(
              'KELUAR AKUN',
              style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFBA1A1A)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
