import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';

class SplashScreen extends StatefulWidget {
  final AppState appState;

  const SplashScreen({super.key, required this.appState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeNext();
  }

  Future<void> _routeNext() async {
    // 2-second delay to show splash, then route
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      widget.appState.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match bg-surface-container-lowest
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Centered Logo Container
              Image.asset(
                'assets/images/logos/logo_srb.webp',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.two_wheeler,
                    size: 100,
                    color: Color(0xFF041627),
                  );
                },
              ),
              const SizedBox(height: 48),
              // Subtle Loading Indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF041627)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
