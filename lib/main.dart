import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pin_code_screen.dart';
import 'services/auth_service.dart';
import 'themes/Light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Моя Ферма',
      debugShowCheckedModeBanner: false,
      theme: Light.theme,
      home: const _StartScreen(),
    );
  }
}

class _StartScreen extends StatefulWidget {
  const _StartScreen();

  @override
  State<_StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<_StartScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final logged = await _authService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = logged;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      return PinCodeScreen(authService: _authService);
    }

    return const LoginScreen();
  }
}