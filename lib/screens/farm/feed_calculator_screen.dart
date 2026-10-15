import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/feed_norm.dart';
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';
import '../../themes/light.dart';
import '../../widgets/app_scaffold.dart';

class FeedCalculatorScreen extends StatefulWidget {
  const FeedCalculatorScreen({super.key});

  @override
  State<FeedCalculatorScreen> createState() => _FeedCalculatorScreenState();
}

class _FeedCalculatorScreenState extends State<FeedCalculatorScreen> {
  final _animalService = AnimalService();
  final _feedService = FeedService();

  Map<AnimalType, List<_AnimalFeed>> _grouped = {};
  double _grandDay = 0;
  double _grandYear = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final animals = await _animalService.getAnimals();
    final grouped = <AnimalType, List<_AnimalFeed>>{};
    double gDay = 0;
    double gYear = 0;

    for (final a in animals) {
      final norms = await _feedService.getNormsForAnimal(a);
      final day = norms.fold<double>(0, (s, n) => s + n.amountPerDay);
      final year = norms.fold<double>(0, (s, n) => s + n.amountPerYear);
      grouped.putIfAbsent(a.type, () => []).add(_AnimalFeed(
            animal: a,
            norms: norms,
            dayTotal: day,
            yearTotal: year,
          ));
      gDay += day;
      gYear += year;
    }

    if (!mounted) return;
    setState(() {
      _grouped = grouped;
      _grandDay = gDay;
      _grandYear = gYear;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      withScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
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
              const SizedBox(width: Light.space3),
              Text('ОТЧЁТНОСТЬ',
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: Light.space4),
          Text('Расход кормов',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 7),
          Text('Сводка потребления по группам животных за день и год.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: Light.space5),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_grouped.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('Нет данных для расчёта',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            )
          else
            ..._grouped.entries.map((e) => _groupBlock(e.key, e.value)),

          if (!_isLoading && _grouped.isNotEmpty) ...[
            const SizedBox(height: Light.space2),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: Light.radiusLg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Общий итог',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: scheme.onPrimary)),
                        const SizedBox(height: 4),
                        Text('Все группы животных',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    scheme.onPrimary.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${_grandDay.toStringAsFixed(0)} кг',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimary)),
                      const SizedBox(height: 2),
                      Text('${_grandYear.toStringAsFixed(0)} кг/год',
                          style: TextStyle(
                              fontSize: 13,
                              color:
                                  scheme.onPrimary.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: Light.space6),
          Center(
            child: Text('Показатели обновляются при наличии данных о рационе',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _groupBlock(AnimalType type, List<_AnimalFeed> items) {
    final scheme = Theme.of(context).colorScheme;
    final groupDay = items.fold<double>(0, (s, e) => s + e.dayTotal);
    final groupYear = items.fold<double>(0, (s, e) => s + e.yearTotal);

    return Padding(
      padding: const EdgeInsets.only(bottom: Light.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: Light.radiusMd,
                ),
                alignment: Alignment.center,
                child: Text(
                  type.displayName.characters.first,
                  style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(type.displayName,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface)),
              const Spacer(),
              Text('${items.length} животных',
                  style: TextStyle(
                      fontSize: 11, color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: Light.radiusLg,
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Light.radiusMedium)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('Животное / корм',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary))),
                      SizedBox(
                          width: 64,
                          child: Text('День',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary))),
                      SizedBox(
                          width: 64,
                          child: Text('Год',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary))),
                    ],
                  ),
                ),
                ...items.map((item) => _animalBlock(item)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    border: Border(
                        top: BorderSide(color: scheme.outline)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('Итого по группе',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface))),
                      SizedBox(
                          width: 64,
                          child: Text(groupDay.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface))),
                      SizedBox(
                          width: 64,
                          child: Text(groupYear.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _animalBlock(_AnimalFeed item) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          child: Row(
            children: [
              Expanded(
                  child: Text(item.animal.name,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface))),
              const SizedBox(width: 64),
              const SizedBox(width: 64),
            ],
          ),
        ),
        ...item.norms.map((n) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(n.feedType.displayName,
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant)),
                    ),
                  ),
                  SizedBox(
                      width: 64,
                      child: Text(n.amountPerDay.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurface))),
                  SizedBox(
                      width: 64,
                      child: Text(n.amountPerYear.toStringAsFixed(0),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurface))),
                ],
              ),
            )),
      ],
    );
  }
}

class _AnimalFeed {
  final Animal animal;
  final List<FeedNorm> norms;
  final double dayTotal;
  final double yearTotal;

  _AnimalFeed({
    required this.animal,
    required this.norms,
    required this.dayTotal,
    required this.yearTotal,
  });
}