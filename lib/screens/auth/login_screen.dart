import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';
import 'pin_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscure = true;
  bool _loading = false;

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
      _show('Заполните все поля');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await _authService.login(login, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PinCodeScreen(authService: _authService, user: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _show(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 38),

          // ==================== HERO ====================
          // Фон/градиент меняется по теме, SVG-иллюстрация лежит сверху.
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const RadialGradient(
                        center: Alignment(-0.5, -0.7),
                        radius: 1.2,
                        colors: [
                          Color(0xFF2A3322),
                          Color(0xFF1F241A),
                          Color(0xFF3A2A18),
                        ],
                      )
                    : const RadialGradient(
                        center: Alignment(-0.5, -0.7),
                        radius: 1.2,
                        colors: [
                          Color(0xFFD5E2B7),
                          Color(0xFFE9E3CE),
                          Color(0xFFF7C98E),
                        ],
                      ),
              ),
              child: Stack(
                children: [
                  // Плашка «Личный кабинет фермы»
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _PillBadge(
                      text: 'Личный кабинет фермы',
                      isDark: isDark,
                    ),
                  ),
                  // SVG-иллюстрация
                  Center(
                    child: SizedBox(
                      width: 195,
                      height: 195,
                      child: SvgPicture.asset(
                        'assets/svgs/login_hero.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 29),

          // ==================== ЗАГОЛОВОК ====================
          Text(
            'С возвращением',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Введите логин и пароль, чтобы продолжить',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 16, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 26),

          // ==================== ПОЛЯ ====================
          _Field(
            controller: _loginController,
            placeholder: 'Логин',
            icon: Icons.person_outline,
            autofillHints: const [AutofillHints.username],
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _Field(
            controller: _passwordController,
            placeholder: 'Пароль',
            icon: Icons.lock_outline,
            obscure: _obscure,
            autofillHints: const [AutofillHints.password],
            isDark: isDark,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: isDark
                    ? const Color(0xFF6F6B5F)
                    : scheme.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 2),

          // ==================== ЗАБЫЛИ ПАРОЛЬ ====================
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _show('Восстановление пароля — скоро'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                minimumSize: const Size(0, 40),
                foregroundColor: scheme.primary,
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Забыли пароль?'),
            ),
          ),
          const SizedBox(height: 10),

          // ==================== КНОПКА ВОЙТИ ====================
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: _loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: scheme.onPrimary, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: scheme.onPrimary,
                        ),
                      ],
                    ),
            ),
          ),

          // ==================== РЕГИСТРАЦИЯ ====================
          const SizedBox(height: 44),
          Center(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14, color: scheme.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'Нет аккаунта? '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => _show('Регистрация — скоро'),
                      child: Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ==================== HOME INDICATOR ====================
          Center(
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFF5F5F2)
                    : const Color(0xFF171914),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ПЛАШКА ====================
class _PillBadge extends StatelessWidget {
  final String text;
  final bool isDark;
  const _PillBadge({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC252A20) : const Color(0xE0FFFFFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFD0D0C4) : const Color(0xFF34372B),
        ),
      ),
    );
  }
}

// ==================== ПОЛЕ ВВОДА ====================
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  final bool isDark;

  const _Field({
    required this.controller,
    required this.placeholder,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.suffix,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bg = isDark ? const Color(0xFF1B1E17) : scheme.surface;
    final border = isDark ? const Color(0xFF303629) : scheme.outline;
    final textColor = isDark ? const Color(0xFF6F6B5F) : scheme.onSurface;
    final hintColor =
        isDark ? const Color(0xFF6F6B5F) : scheme.onSurfaceVariant;
    final iconColor =
        isDark ? const Color(0xFF6F6B5F) : scheme.onSurfaceVariant;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(width: 13),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              autofillHints: autofillHints,
              style: TextStyle(fontSize: 16, color: textColor),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
                hintText: placeholder,
                hintStyle: TextStyle(fontSize: 16, color: hintColor),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}