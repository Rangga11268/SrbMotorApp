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

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle links when app is in background or closed
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    if (uri.scheme == 'srbmotor' && uri.host == 'payment-success') {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
        
        final mainProvider = context.read<MainProvider>();
        final orderProvider = context.read<OrderProvider>();
        final authProvider = context.read<AuthProvider>();

        if (authProvider.isAuthenticated) {
          mainProvider.setSelectedIndex(1); // Go to Orders tab
          
          // Manual Status Sync if IDs are present
          final queryParams = uri.queryParameters;
          if (queryParams.containsKey('installment_id')) {
            final id = int.tryParse(queryParams['installment_id'] ?? '');
            if (id != null) {
              orderProvider.refreshOrderStatus(id);
            } else {
              orderProvider.fetchOrderHistory();
            }
          } else if (queryParams.containsKey('installment_ids')) {
            final idsStr = queryParams['installment_ids'] ?? '';
            final ids = idsStr.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
            if (ids.isNotEmpty) {
              // Refresh first one is usually enough to trigger the sync logic, 
              // but we can loop or just reload history
              orderProvider.refreshOrderStatus(ids.first);
            } else {
              orderProvider.fetchOrderHistory();
            }
          } else {
            orderProvider.fetchOrderHistory(); 
          }
        }
      }
    }
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
            duration: const Duration(milliseconds: 500),
            child: currentScreen,
          );
        },
      ),
    );
  }
}
