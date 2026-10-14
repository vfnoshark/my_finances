import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/farm_stats.dart';
import '../../models/feed_norm.dart'; 
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';

class FeedCalculatorScreen extends StatefulWidget {
  const FeedCalculatorScreen({super.key});

  @override
  State<FeedCalculatorScreen> createState() => _FeedCalculatorScreenState();
}

class _FeedCalculatorScreenState extends State<FeedCalculatorScreen> {
  final AnimalService _animalService = AnimalService();
  final FeedService _feedService = FeedService();

  FarmStats? _stats;
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
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  /// Pull-to-refresh
  Future<void> _refresh() async {
    await _animalService.refresh();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Light.background,
      appBar: AppBar(
        title: const Text('Расчёт кормов'),
        backgroundColor: Light.olive,
        foregroundColor: Light.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null || _stats!.feedBreakdown.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'Нет данных для расчёта',
                          style: TextStyle(
                            fontSize: 16,
                            color: Light.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Годовая потребность в кормах',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Всего животных: ${_stats!.totalAnimals}',
                        style: const TextStyle(color: Light.textMuted),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Light.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Light.olive,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Тип корма',
                                      style: TextStyle(
                                        color: Light.surface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'На год',
                                    style: TextStyle(
                                      color: Light.surface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._stats!.feedBreakdown.entries.map((entry) {
                              return _buildTableRow(
                                entry.key.displayName,
                                '${entry.value.toStringAsFixed(0)} кг',
                              );
                            }),
                            _buildTableRow(
                              'Итого',
                              '${_stats!.totalFeedPerYear.toStringAsFixed(0)} кг',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTableRow(String label, String value, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Light.outline),
        ),
        color: isTotal ? Light.surfaceMuted : Light.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Light.olive : Light.text,
            ),
          ),
        ],
      ),
    );
  }
}