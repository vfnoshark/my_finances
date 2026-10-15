import 'package:flutter/material.dart';
import '../../main.dart' show themeNotifier;
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _storage = LocalStorageService();

  String _name = '';
  String _login = '';
  bool _loading = true;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _auth.getUserName();
    final login = await _auth.getUserLogin();
    final saved = await _storage.getDarkTheme();
    final systemDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    if (!mounted) return;
    setState(() {
      _name = name;
      _login = login;
      // Если пользователь не выбирал — берём текущее состояние системы
      _darkTheme = saved ?? systemDark;
      _loading = false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => _darkTheme = value);
    await _storage.setDarkTheme(value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      withScroll: true,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: Light.radiusMd,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: Light.radiusMd,
                        border: Border.all(color: scheme.outline),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: scheme.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Light.space4),

                // Профиль
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2A3322), const Color(0xFF3A2A18)]
                          : [const Color(0xFFE3E8D2), const Color(0xFFEEE3CF)],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF3A4229)
                              : const Color(0xFFDEDEDB),
                          border: Border.all(
                            color: isDark
                                ? const Color(0x33FFFFFF)
                                : const Color(0x85FFFFFF),
                            width: 5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: isDark
                              ? const Color(0xFFB8CF7C)
                              : const Color(0xFF8A8C80),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: scheme.onSurface)),
                      const SizedBox(height: 6),
                      Text(_login,
                          style: TextStyle(
                              fontSize: 13, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: Light.space5),

                // Данные аккаунта
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('ДАННЫЕ АККАУНТА',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: scheme.primary)),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: Light.radiusLg,
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Имя пользователя', _name, context),
                      _infoRow('Логин', _login, context, last: true),
                    ],
                  ),
                ),

                const SizedBox(height: Light.space5),

                // Настройки
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('НАСТРОЙКИ',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: scheme.primary)),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: Light.radiusLg,
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _darkTheme
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Тёмная тема',
                            style: TextStyle(
                                fontSize: 14, color: scheme.onSurface),
                          ),
                        ),
                        Switch(
                          value: _darkTheme,
                          onChanged: _toggleTheme,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: Light.space5),

                ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF3A1F1F)
                        : const Color(0xFFF0D5D0),
                    foregroundColor: isDark
                        ? const Color(0xFFE58585)
                        : const Color(0xFF8D4546),
                    minimumSize: const Size(0, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Выйти из учётной записи',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'После выхода для продолжения потребуется войти снова.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: Light.space6),
                Center(
                  child: Text('Личный кабинет фермы',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value, BuildContext context,
      {bool last = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: scheme.outline)),
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: scheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
        ],
      ),
    );
  }
}