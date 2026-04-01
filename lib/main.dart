import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import './providers/auth_provider.dart';
import './providers/motor_provider.dart';
import './providers/order_provider.dart';
import './providers/main_provider.dart';
import 'providers/notification_provider.dart';
import './screens/splash/splash_screen.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import './screens/home/home_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/menu/order_status_screen.dart';

MidtransSDK? midtrans;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ganti 'YOUR_CLIENT_KEY' dan 'YOUR_BASE_URL' dengan kunci asli dari .env
  midtrans = await MidtransSDK.init(
    config: MidtransConfig(
      clientKey: "YOUR_CLIENT_KEY",
      merchantBaseUrl: "https://your-api.com/", // Placeholder
      colorTheme: ColorTheme(
        colorPrimary: const Color(0xFF2563EB),
        colorPrimaryDark: const Color(0xFF1D4ED8),
        colorSecondary: const Color(0xFF3B82F6),
      ),
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MotorProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

    // NOTE: We intentionally do NOT call getInitialLink() here.
    // getInitialLink() caches the last received URI at the OS level and re-fires it
    // on cold start, which causes it to navigate to OrderStatusScreen BEFORE the
    // splash screen is dismissed — breaking normal app startup flow.
    //
    // For payment redirect flows, uriLinkStream is sufficient:
    // the app is always running in the background during payment (user just switches
    // to browser), so when browser redirects to srbmotor://, uriLinkStream fires.

    // Handle links when app is resumed from background (e.g. after payment in browser).
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Foreground deep link received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) => debugPrint('Deep link stream error: $err'));
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'srbmotor') return;

    Future.microtask(() async {
      if (!mounted) return;

      try {
        // Guard: wait until splash is gone and user is on the main app
        // This prevents navigating to OrderStatusScreen before HomeScreen exists
        int waitCount = 0;
        while (_showSplash && waitCount < 20) {
          await Future.delayed(const Duration(milliseconds: 300));
          waitCount++;
        }
        if (!mounted) return;
        if (_showSplash) return; // Still on splash after timeout, abort

        // Extra settle time so HomeScreen navigator is ready
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;

        final isPaymentEvent =
            uri.host == 'payment-success' ||
            uri.host == 'payment-finish' ||
            uri.host == 'payment-error' ||
            uri.host == 'payment-pending';

        if (!isPaymentEvent) return;

        // Auto-dismiss splash screen so we can navigate to HomeScreen/OrderStatus
        if (_showSplash) {
          setState(() {
            _showSplash = false;
          });
        }

        final transactionIdStr = uri.queryParameters['transaction_id'];
        final orderProvider = context.read<OrderProvider>();
        final mainProvider = context.read<MainProvider>();

        // 1. Safely return to HomeScreen root by popping all overlays
        final navState = _navigatorKey.currentState;
        if (navState != null) {
          while (navState.canPop()) {
            navState.pop();
          }
        }

        // 2. Switch to Order History tab via MainProvider
        mainProvider.setSelectedIndex(1);

        // 3. Fetch fresh order data
        await orderProvider.fetchOrderHistory();
        if (!mounted) return;

        if (transactionIdStr != null) {
          final orderId = int.tryParse(transactionIdStr);
          if (orderId != null) {
            final orderList = orderProvider.orders;
            final order = orderList.where((o) => o.id == orderId).firstOrNull;

            if (order != null) {
              // Sync installment status with Midtrans logic
              await orderProvider.syncOrderDetails(order);
              if (!mounted) return;

              final refreshedOrder =
                  orderProvider.orders
                      .where((o) => o.id == orderId)
                      .firstOrNull ??
                  order;

              // Ensure a significant delay for UI state to settle after pop loop
              // This is crucial to avoid "black screen" issues on slow devices
              await Future.delayed(const Duration(milliseconds: 500));
              if (!mounted) return;

              // 4. Push OrderStatusScreen on top of HomeScreen
              if (_navigatorKey.currentState != null) {
                _navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderStatusScreen(order: refreshedOrder),
                  ),
                );
              }
            } else {
              debugPrint('Deep link: Order ID $orderId not found in history');
            }
          }
        }

        debugPrint('Deep link fully handled: $uri');
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
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
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
