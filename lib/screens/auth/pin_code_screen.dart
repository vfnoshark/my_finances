import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_scaffold.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class PinCodeScreen extends StatefulWidget {
  final AuthService authService;
  final User? user;

  const PinCodeScreen({
    super.key,
    required this.authService,
    this.user,
  });

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

  void _addDigit(String digit) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += digit);
      if (_pin.length == _pinLength) _handleComplete();
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _handleComplete() async {
    if (_isSetupMode) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        if (_pin == _firstPin) {
          await widget.authService.savePinAndLogin(_pin, widget.user!);
          if (!mounted) return;
          _goHome();
        } else {
          _registerFailure('PIN-коды не совпадают');
        }
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
    _showMessage('$message. Попытка $_attempts из 3');

    if (_attempts >= 3) {
      if (_isSetupMode) {
        setState(() {
          _attempts = 0;
          _pin = '';
          _firstPin = null;
          _isConfirming = false;
        });
        _showMessage('Слишком много попыток. Придумайте новый PIN.');
      } else {
        await widget.authService.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() => _pin = '');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSetupMode
        ? (_isConfirming ? 'Повторите PIN-код' : 'Придумайте PIN-код')
        : 'Введите PIN-код';

    final subtitle = _isSetupMode
        ? (_isConfirming
            ? 'Введите те же 4 цифры'
            : 'Он понадобится для входа в приложение')
        : 'Для входа в приложение';

    return AppScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 56,
            color: Light.olive,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Light.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Light.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              final isFilled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? Light.olive : Colors.transparent,
                  border: Border.all(
                    color: isFilled ? Light.olive : Light.textMuted,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildKeyboard(),
        ],
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var j = 1; j <= 3; j++)
                _buildKey('${i * 3 + j}'),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72),
            _buildKey('0'),
            _buildKey('del', isDelete: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label, {bool isDelete = false}) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      width: 68,
      height: 68,
      child: Material(
        color: Light.surface,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => isDelete ? _removeDigit() : _addDigit(label),
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 24,
                    color: Light.text,
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Light.text,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}