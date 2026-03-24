import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            onPressed: () => authProvider.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2563EB),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Pengguna',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'email@example.com',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            _buildProfileItem(Icons.phone_outlined, 'Nomor Telepon', user?.phone ?? '-'),
            _buildProfileItem(Icons.location_on_outlined, 'Alamat', 'Bekasi, Jawa Barat'),
            _buildProfileItem(Icons.security_outlined, 'Keamanan Akun', 'Ubah Password'),
            _buildProfileItem(Icons.help_outline, 'Pusat Bantuan', 'Hubungi CS'),
            
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () => authProvider.logout(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('KELUAR AKUN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
