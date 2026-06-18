import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'screens/auth/login_screen_simple.dart';
import 'screens/home/home_screen_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appState = AppState();
  await appState.init();
  
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;

  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRB Motor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: appState.isAuthenticated
          ? HomeScreen(appState: appState)
          : LoginScreen(appState: appState),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomeScreen(appState: appState),
          );
        }
        return null;
      },
    );
  }
}

