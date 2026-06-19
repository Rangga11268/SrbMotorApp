import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email dan password harus diisi';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await widget.appState.login(email, password);

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        errorMessage = 'Email atau password salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches bg-surface-container-lowest
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo Container
              Center(
                child: Image.asset(
                  'assets/images/logos/logo_srb.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.two_wheeler,
                      size: 64,
                      color: Color(0xFF041627),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF041627), // primary
                ),
              ),
              const SizedBox(height: 48),
              // Email field (Bottom border style)
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF041627), width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF041627)),
              ),
              const SizedBox(height: 24),
              // Password field (Bottom border style)
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF041627), width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF041627)),
              ),
              const SizedBox(height: 12),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ],
              const SizedBox(height: 40),
              // CTA Button (Masuk)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF041627), // primary container color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // rounded-DEFAULT (minimal)
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'MASUK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              // Auxiliary links
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan hubungi admin untuk reset password'),
                          ),
                        );
                      },
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Color(0xFF5F5E5E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/register');
                      },
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: Color(0xFF041627),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
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
