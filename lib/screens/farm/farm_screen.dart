import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/farm_stats.dart';
import '../../models/feed_norm.dart';
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';
import 'animal_list_screen.dart';
import 'feed_calculator_screen.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final AnimalService _animalService = AnimalService();
  final FeedService _feedService = FeedService();

  FarmStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final animals = await _animalService.getAnimals();
    final stats = await _feedService.calculateFarmStats(animals);

    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  /// Pull-to-refresh: принудительно перечитываем из хранилища
  Future<void> _refreshStats() async {
    await _animalService.refresh();
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Light.background,
      appBar: AppBar(
        title: const Text('Моя ферма'),
        backgroundColor: Light.olive,
        foregroundColor: Light.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshStats,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Light.olive,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Сводка по хозяйству',
                          style: TextStyle(
                            color: Light.surfaceMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Животных',
                              '${_stats?.totalAnimals ?? 0}',
                            ),
                            _buildStatItem(
                              'Корм/год',
                              '${(_stats?.totalFeedPerYear ?? 0).toStringAsFixed(0)} кг',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_stats != null && _stats!.feedBreakdown.isNotEmpty) ...[
                    const Text(
                      'Разбивка по кормам',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._stats!.feedBreakdown.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Light.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.displayName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(0)} кг',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Light.olive,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                  _buildActionButton(
                    context,
                    icon: Icons.pets,
                    title: 'Мои животные',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnimalListScreen(),
                        ),
                      );
                      _loadStats();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    icon: Icons.table_chart,
                    title: 'Общий расчёт кормов',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Light.surface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Light.surfaceMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Light.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Light.olive),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Light.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}