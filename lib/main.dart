import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/motor_provider.dart';
import './providers/order_provider.dart';
import './providers/main_provider.dart';
import './screens/splash/splash_screen.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import './screens/home/home_screen.dart';
import './screens/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MotorProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MainProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() {
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().checkAuth();
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // 1. Handle initial link (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // 2. Handle links when app is in background or foreground
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint('Deep link stream error: $err'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Processing deep link: $uri');
    
    // Safety check for specific host
    if (uri.scheme != 'srbmotor' || uri.host != 'payment-success') return;

    // Use microtask to ensure context is stable and not in the middle of a build
    Future.microtask(() {
      if (!mounted) return;

      try {
        // Hide splash immediately if we got a valid link
        if (_showSplash) {
          setState(() {
            _showSplash = false;
          });
        }
        
        // Manual refresh is now preferred by the user. 
        // We just hide the splash and let the user navigate/refresh manually.
        debugPrint('Deep link received (Auto-refresh disabled per user request): $uri');
      } catch (e) {
        debugPrint('Error handling deep link: $e');
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRB Motor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          Widget currentScreen;

          if (_showSplash) {
            currentScreen = SplashScreen(
              key: const ValueKey('splash_screen'),
              onGetStarted: () {
                setState(() {
                  _showSplash = false;
                });
              },
            );
          } else if (auth.isAuthenticated) {
            currentScreen = const HomeScreen(key: ValueKey('home_screen'));
          } else {
            currentScreen = const LoginScreen(key: ValueKey('login_screen'));
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: currentScreen,
          );
        },
      ),
    );
  }
}
