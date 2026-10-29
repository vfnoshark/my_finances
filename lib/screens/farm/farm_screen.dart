import 'package:flutter/material.dart';
import '../../models/farm_stats.dart';
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';
import 'animal_list_screen.dart';
import 'feed_calculator_screen.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final _animalService = AnimalService();
  final _feedService = FeedService();

  FarmStats? _stats;
  double _dayTotal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final animals = await _animalService.getAnimals();
    final stats = await _feedService.calculateFarmStats(animals);

    double day = 0;
    for (final a in animals) {
      final norms = await _feedService.getNormsForAnimal(a);
      day += norms.fold<double>(0, (s, n) => s + n.amountPerDay);
    }

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _dayTotal = day;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final summaryColors = isDark
        ? const [Color(0xFF4E331B), Color(0xFF3A4A22)]
        : const [Color(0xFFC9A875), Color(0xFF6B7A45)];

    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8), // было больше

          // Кнопка "назад"
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
                child: Icon(Icons.chevron_left,
                    color: scheme.primary, size: 26),
              ),
            ),
          ),
          const SizedBox(height: Light.space4), // было Light.space5

          Text('Моя ферма',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: scheme.onSurface,
                  )),
          const SizedBox(height: 7),
          Text('Управляйте животными и кормами',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: Light.space4),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Container(
              padding: const EdgeInsets.all(Light.space5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: summaryColors,
                ),
                borderRadius: Light.radiusLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Потребность в кормах',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFF5E0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('В день',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFFF5E0))),
                          const SizedBox(height: 4),
                          Text(
                            '${_dayTotal.toStringAsFixed(1)} кг',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('В год',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFFF5E0))),
                          const SizedBox(height: 4),
                          Text(
                            '${(_stats?.totalFeedPerYear ?? 0).toStringAsFixed(0)} кг',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Light.space4),
          ],

          _FarmLink(
            icon: Icons.pets,
            title: 'Мои животные',
            subtitle: 'Список и карточки',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnimalListScreen()),
              );
              _load();
            },
          ),
          const SizedBox(height: Light.space3),
          _FarmLink(
            icon: Icons.table_chart_outlined,
            title: 'Расход кормов',
            subtitle: 'Отчёт по группам',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FeedCalculatorScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FarmLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: Light.radiusLg,
      child: InkWell(
        borderRadius: Light.radiusLg,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: Light.radiusLg,
            border: Border.all(color: scheme.outline),
          ),
          padding: const EdgeInsets.all(Light.space4),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: Light.radiusMd,
                ),
                child: Icon(icon, color: scheme.onPrimary, size: 28),
              ),
              const SizedBox(width: Light.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: scheme.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}