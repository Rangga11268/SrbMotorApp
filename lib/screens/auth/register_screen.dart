import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // Navigation handled by Consumer in main.dart
      } catch (e) {
        if (mounted) {
          _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showLogo: false,
        title: 'Daftar Akun Baru',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/logos/logo_srb.webp',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.motorcycle,
                      size: 80,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Buat Akun Baru',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi data diri Anda untuk bergabung',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.blueGrey, fontSize: 15),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Nama Lengkap', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Nomor Telepon', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('DAFTAR SEKARANG', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.blueGrey),
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF2563EB),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label tidak boleh kosong';
        if (label == 'Email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Format email tidak valid';
        }
        if (label == 'Password' && value.length < 8) {
          return 'Password minimal 8 karakter';
        }
        if (label == 'Nomor Telepon' && !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Nomor telepon hanya boleh angka';
        }
        return null;
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gagal Daftar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.outfit()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }
}
