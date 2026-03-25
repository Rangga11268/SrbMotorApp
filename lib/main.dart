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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Hide splash immediately if we got a valid link
        if (_showSplash) {
          setState(() {
            _showSplash = false;
          });
        }

        if (authProvider.isAuthenticated) {
          final mainProvider = Provider.of<MainProvider>(context, listen: false);
          final orderProvider = Provider.of<OrderProvider>(context, listen: false);

          // Change tab to Orders
          mainProvider.setSelectedIndex(1);
          
          final queryParams = uri.queryParameters;
          
          // Execute refresh logic
          if (queryParams.containsKey('installment_id')) {
            final id = int.tryParse(queryParams['installment_id'] ?? '');
            if (id != null) orderProvider.refreshOrderStatus(id);
          } else if (queryParams.containsKey('installment_ids')) {
            final idsStr = queryParams['installment_ids'] ?? '';
            final ids = idsStr.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
            if (ids.isNotEmpty) orderProvider.refreshOrderStatus(ids.first);
          } else {
            orderProvider.fetchOrderHistory();
          }
        }
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
