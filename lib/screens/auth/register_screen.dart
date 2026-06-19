import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';

class RegisterScreen extends StatefulWidget {
  final AppState appState;

  const RegisterScreen({super.key, required this.appState});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Semua field harus diisi';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await widget.appState.register(email, name, phone, password);

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
        errorMessage = 'Pendaftaran gagal. Lengkapi data dengan benar.';
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
              const SizedBox(height: 16),
              // Header title
              const Text(
                'Daftar Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF041627), // primary
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bergabunglah dengan kami untuk pengalaman terbaik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: Color(0xFF5F5E5E),
                ),
              ),
              const SizedBox(height: 40),
              // Registration Card Container
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Nama Lengkap',
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
                      const SizedBox(height: 20),
                      // WhatsApp Number
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Nomor WhatsApp',
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
                      const SizedBox(height: 20),
                      // Email
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
                      const SizedBox(height: 20),
                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          fillColor: Colors.transparent,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFC4C6CD)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF041627), width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF5F5E5E),
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF041627)),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // CTA Button (Daftar)
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF041627), // primary container
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
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
                                  'DAFTAR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Footer link (Sudah punya akun? Masuk)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: Color(0xFF5F5E5E),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF041627),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
