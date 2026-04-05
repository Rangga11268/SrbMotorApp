import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(showLogo: false, title: 'Profil Saya'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Profile Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.2),
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.name ?? 'Pengguna',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderStat('Unit', '1'),
                      Container(
                        height: 40,
                        width: 1,
                        color: const Color(0xFFF1F5F9),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      _buildHeaderStat('Status', 'Platinum'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF2563EB,
                        ).withOpacity(0.05),
                        foregroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        'EDIT PROFIL',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PENGATURAN AKUN',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(
                    context,
                    Icons.phone_outlined,
                    'Nomor Telepon',
                    user?.phone ?? '-',
                    Colors.blue[600]!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.location_on_outlined,
                    'Alamat Utama',
                    user?.alamat ?? 'Belum diset',
                    Colors.orange[600]!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.security_outlined,
                    'Keamanan Akun',
                    'Ubah Password',
                    Colors.purple[600]!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'LAINNYA',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(
                    context,
                    Icons.help_outline,
                    'Pusat Bantuan',
                    'Hubungi CS',
                    Colors.teal[600]!,
                    onTap: () => _launchHelpWhatsApp(),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.info_outline,
                    'Info Aplikasi',
                    'Versi 1.0.0',
                    Colors.blueGrey[600]!,
                    onTap: () => _showAppInfo(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  // Consumer in main.dart auto-navigates to LoginScreen
                  // when isAuthenticated becomes false
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: Colors.red[700],
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'KELUAR AKUN',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _launchHelpWhatsApp() async {
    final message = Uri.encodeComponent(
      'Halo SRB Motor, saya butuh bantuan mengenai pengajuan atau unit di aplikasi.',
    );
    final url = Uri.parse('https://wa.me/628978638849?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAppInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/images/logos/logo_srb.webp',
                  width: 70,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.motorcycle,
                    size: 32,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SRB Motor App',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versi 1.0.0 Stable',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                '"Solusi Kendaraan Impian Anda"\nDealer resmi di bawah naungan SSM.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'TUTUP',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 18,
          color: Color(0xFFCBD5E1),
        ),
        onTap: onTap,
      ),
    );
  }
}
