import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';
import '../farm/farm_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String _houseSvg = '''
<svg viewBox="0 0 160 150" fill="none">
<path d="M25 75 80 30l55 45v52H25V75Z" fill="#E6B15F"/>
<path d="M18 77 80 24l62 53-7 8-55-46-55 46-7-8Z" fill="#D89D4C"/>
<path d="M59 91h42v36H59z" fill="#4E5B32"/>
<path d="M75 45h11v11H75z" fill="#4E5B32"/>
<path d="M13 131c23-21 48-22 70-8 18-15 39-16 64-2v20H13v-10Z" fill="#7F8952"/>
<path d="M19 140c29-18 47-24 69-18l-19 18H19Z" fill="#DDB66F"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final heroColors = isDark
        ? const [Color(0xFF2A3322), Color(0xFF3A2A18)]
        : const [Color(0xFFD6E0B8), Color(0xFFEBE4D0)];

    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: Light.radiusXl,
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.7),
                radius: 1.2,
                colors: heroColors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: _PillBadge(
                    text: 'Личный кабинет фермы',
                    isDark: isDark,
                  ),
                ),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0x33F7F1E2)
                          : const Color(0xB8F7F1E2),
                    ),
                    alignment: Alignment.center,
                    child:
                        SvgPicture.string(_houseSvg, width: 94, height: 94),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Light.space6),

          Text('Добро пожаловать!',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 7),
          Text('Всё о вашей ферме — в одном месте.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),

          const SizedBox(height: Light.space6),

          _MenuLink(
            icon: Icons.agriculture,
            label: 'Моя ферма',
            color: isDark ? const Color(0xFF2A3322) : const Color(0xFFE0D2B3),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FarmScreen())),
          ),
          const SizedBox(height: Light.space3),
          _MenuLink(
            icon: Icons.person_outline,
            label: 'Профиль',
            color: isDark ? const Color(0xFF262B20) : const Color(0xFFE9E0CA),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),

          const SizedBox(height: Light.space8),
          Center(
            child: Text('Забота о ферме начинается здесь',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String text;
  final bool isDark;
  const _PillBadge({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC252A20) : const Color(0xD9FFFDF4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFD0D0C4)
                  : const Color(0xFF424735))),
    );
  }
}

class _MenuLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Иконка-квадрат: тёмная тема — оливковая (scheme.primary), светлая — тоже
    // scheme.primary. Текст на кнопке: onPrimary. Стрелка: primary.
    return Material(
      color: color,
      borderRadius: Light.radiusLg,
      child: InkWell(
        borderRadius: Light.radiusLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Light.space4),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: Light.radiusMd,
                ),
                child: Icon(icon, color: scheme.onPrimary, size: 32),
              ),
              const SizedBox(width: Light.space4),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? scheme.onSurface : Light.text,
                        letterSpacing: -0.3)),
              ),
              Icon(Icons.arrow_forward,
                  color: scheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}