import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:app_links/app_links.dart';
import 'package:srb_motor_app/providers/auth_provider.dart';
import 'package:srb_motor_app/providers/motor_provider.dart';
import 'package:srb_motor_app/providers/order_provider.dart';
import 'package:srb_motor_app/providers/main_provider.dart';
import 'package:srb_motor_app/providers/notification_provider.dart';
import 'package:srb_motor_app/providers/service_provider.dart';
import './screens/splash/splash_screen.dart';
import './screens/home/home_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/menu/order_status_screen.dart';

MidtransSDK? midtrans;
const String MIDTRANS_CLIENT_KEY = "Mid-client-aAUNIuf1fCSll2qz";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  midtrans = await MidtransSDK.init(
    config: MidtransConfig(
      clientKey: MIDTRANS_CLIENT_KEY,
      merchantBaseUrl: "https://jerrie-lagoonal-cherryl.ngrok-free.dev/api/",
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
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
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
    _initMidtransCallback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().checkAuth();
      }
    });
  }

  void _initMidtransCallback() {
    midtrans?.setTransactionFinishedCallback((result) {
      debugPrint(
        'Midtrans Transaction Finished: ${result.transactionId}, Status: ${result.status}',
      );

      // Ketika transaksi selesai (baik sukses, batal, atau pending),
      // paksa pengecekan otomatis (sync) ke backend agar status "Lunas" instan
      final orderProvider = context.read<OrderProvider>();
      final serviceProvider = context.read<ServiceProvider>();
      if (mounted) {
        orderProvider.syncActivePayment();
        serviceProvider.syncServiceHistory();
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    bool isColdStart = true;
    Timer(const Duration(seconds: 2), () {
      isColdStart = false;
      debugPrint('Cold start period ended, deep links now accepted');
    });

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (isColdStart) {
        debugPrint('Ignoring cold start deep link: $uri');
        return;
      }
      debugPrint('Foreground deep link received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) => debugPrint('Deep link stream error: $err'));
  }

  final Set<String> _processedLinks = {};

  void _handleDeepLink(Uri uri) {
    // Only process srbmotor:// scheme
    if (uri.scheme != 'srbmotor') {
      debugPrint('Ignoring non-app deep link: $uri');
      return;
    }

    // Guard against processing the same link multiple times in a short window
    final linkKey = uri.toString();
    if (_processedLinks.contains(linkKey)) {
      debugPrint('Deep link already processed: $linkKey');
      return;
    }
    _processedLinks.add(linkKey);
    // Auto-clean after 5 seconds to allow legitimate re-clicks if needed
    Timer(const Duration(seconds: 5), () => _processedLinks.remove(linkKey));

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
    midtrans?.removeTransactionFinishedCallback();
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
        textTheme: GoogleFonts.interTextTheme(),
        primaryTextTheme: GoogleFonts.interTextTheme(),
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
