import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_scaffold.dart';
import 'pin_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      _showMessage('Заполните все поля');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(login, password);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PinCodeScreen(
            authService: _authService,
            user: user,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const Icon(
            Icons.agriculture,
            size: 72,
            color: Light.olive,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Моя Ферма',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Light.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Войдите в свой аккаунт',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Light.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          TextField(
            controller: _loginController,
            decoration: const InputDecoration(
              labelText: 'Логин',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Пароль',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Light.surface,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Войти'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          const Text(
            'Тестовые данные: admin / 12345',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Light.textMuted),
          ),
        ],
      ),
    );
  }
}