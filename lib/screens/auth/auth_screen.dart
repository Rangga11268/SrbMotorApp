import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';

const _surfaceBg = Color(0xFFF5F7FB);

class LoginScreen extends StatelessWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(appState: appState, isLogin: true);
  }
}

class RegisterScreen extends StatelessWidget {
  final AppState appState;

  const RegisterScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AuthScreen(appState: appState, isLogin: false);
  }
}

class AuthScreen extends StatefulWidget {
  final AppState appState;
  final bool isLogin;

  const AuthScreen({
    super.key,
    required this.appState,
    required this.isLogin,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = widget.isLogin
        ? await widget.appState.login(emailController.text.trim(), passwordController.text)
        : await widget.appState.register(
            emailController.text.trim(),
            nameController.text.trim(),
            phoneController.text.trim(),
            passwordController.text,
          );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    setState(() {
      errorMessage = widget.isLogin
          ? 'Email atau password salah'
          : 'Lengkapi data dengan benar';
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), _surfaceBg],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildHeroCard(primary),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isLogin ? 'Masuk' : 'Daftar',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.isLogin
                              ? 'Lanjutkan ke katalog motor dan simpan wishlist.'
                              : 'Buat akun baru untuk mulai melihat katalog motor.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (!widget.isLogin) ...[
                          _buildField(
                            controller: nameController,
                            label: 'Nama lengkap',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: phoneController,
                            label: 'Nomor telepon',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                        ],
                        _buildField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Color(0xFFB91C1C)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(widget.isLogin ? 'Masuk' : 'Daftar'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                widget.isLogin ? '/register' : '/login',
                              );
                            },
                            child: Text(
                              widget.isLogin
                                  ? 'Belum punya akun? Daftar'
                                  : 'Sudah punya akun? Masuk',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(Color primary) {
    return Card(
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, const Color(0xFF1D4ED8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 24,
              bottom: 24,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/banner/banner.webp',
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logos/logo_srb.webp',
                      width: 42,
                      height: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SRB Motor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tampilan sederhana, rapi, dan enak dilihat.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
