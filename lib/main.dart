import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pin_code_screen.dart';
import 'services/auth_service.dart';
import 'services/local_storage_service.dart';
import 'themes/dark.dart';
import 'themes/light.dart';

/// Глобальный контроллер темы.
/// null  — следуем за системой
/// true  — тёмная
/// false — светлая
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем сохранённый выбор темы ДО запуска приложения
  final saved = await LocalStorageService().getDarkTheme();
  if (saved == true) {
    themeNotifier.value = ThemeMode.dark;
  } else if (saved == false) {
    themeNotifier.value = ThemeMode.light;
  } else {
    themeNotifier.value = ThemeMode.system;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Моя Ферма',
          debugShowCheckedModeBanner: false,
          theme: Light.theme,
          darkTheme: Dark.theme,
          themeMode: mode,
          home: const _StartScreen(),
        );
      },
    );
  }
}

class _StartScreen extends StatefulWidget {
  const _StartScreen();

  @override
  State<_StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<_StartScreen> {
  final _auth = AuthService();
  bool _loading = true;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final logged = await _auth.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _logged = logged;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _logged
        ? PinCodeScreen(authService: _auth)
        : const LoginScreen();
  }
}