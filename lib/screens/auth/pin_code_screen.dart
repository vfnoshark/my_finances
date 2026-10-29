import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class PinCodeScreen extends StatefulWidget {
  final AuthService authService;
  final User? user;
  const PinCodeScreen({super.key, required this.authService, this.user});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final int _pinLength = 4;
  String _pin = '';
  String? _firstPin;
  int _attempts = 0;
  bool _isConfirming = false;

  bool get _isSetupMode => widget.user != null;

  void _addDigit(String d) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += d);
      if (_pin.length == _pinLength) _handleComplete();
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _reset() {
    setState(() {
      _pin = '';
      _attempts = 0;
      _firstPin = null;
      _isConfirming = false;
    });
  }

  Future<void> _handleComplete() async {
    if (_isSetupMode) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else if (_pin == _firstPin) {
        await widget.authService.savePinAndLogin(_pin, widget.user!);
        if (!mounted) return;
        _goHome();
      } else {
        _registerFailure('PIN-коды не совпадают');
      }
    } else {
      final ok = await widget.authService.verifyPin(_pin);
      if (!mounted) return;
      if (ok) {
        _goHome();
      } else {
        _registerFailure('Неверный PIN');
      }
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _registerFailure(String message) async {
    _attempts++;
    _show('$message. Попытка $_attempts из 3');
    if (_attempts >= 3) {
      if (_isSetupMode) {
        _reset();
        _show('Слишком много попыток. Придумайте новый PIN.');
      } else {
        await widget.authService.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } else {
      setState(() => _pin = '');
    }
  }

  void _show(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = _isSetupMode
        ? (_isConfirming
            ? 'Повторите PIN-код'
            : 'Придумайте PIN-код\nдля быстрого входа')
        : 'Введите PIN-код';
    final subtitle = _isSetupMode
        ? (_isConfirming
            ? 'Введите те же 4 цифры'
            : 'Четыре цифры — и вы сможете входить в приложение быстрее.')
        : 'Для входа в приложение';

    final heroColors = isDark
        ? const [Color(0xFF2A3322), Color(0xFF3A2A18)]
        : const [Color(0xFFD6E0B8), Color(0xFFEBE4D0)];

    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Кнопка "назад" убрана

          Container(
            padding: const EdgeInsets.all(Light.space5),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -1),
                radius: 1.4,
                colors: heroColors,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(26)),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x33F7F1E2)
                        : const Color(0xA8FFFDF0),
                    borderRadius: const BorderRadius.all(Radius.circular(23)),
                  ),
                  child: Icon(Icons.lock_outline,
                      size: 43, color: scheme.primary),
                ),
                const SizedBox(height: 14),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 9),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: Light.space5),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (i) {
              final active = i < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: active ? 14 : 13,
                height: active ? 14 : 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? scheme.primary : scheme.outline,
                ),
              );
            }),
          ),
          const SizedBox(height: Light.space5),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 285),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  for (int i = 1; i <= 9; i++) _key('$i'),
                  _key('⌫', isClear: true, onTap: _removeDigit),
                  _key('0'),
                  _key('Сброс', isClear: true, fontSize: 14, onTap: _reset),
                ],
              ),
            ),
          ),
          const SizedBox(height: Light.space4),
          Center(
            child: Text(
              _pin.length == _pinLength
                  ? (_isSetupMode ? 'PIN-код создан!' : '')
                  : 'Введите первую цифру',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: Light.space6),
          Center(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'Ваши данные останутся '),
                  TextSpan(
                    text: 'в безопасности',
                    style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String label,
      {bool isClear = false, double fontSize = 24, VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isClear
          ? (isDark ? const Color(0xFF262B20) : const Color(0xFFE9E0CA))
          : (isDark ? const Color(0xFF3A4229) : const Color(0xFFD3B789)),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => _addDigit(label),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
        ),
      ),
    );
  }
}