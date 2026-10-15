import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/feed_norm.dart';
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';
import '../../themes/light.dart';
import '../../widgets/animal_icon.dart';
import '../../widgets/app_scaffold.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final FeedService _feedService = FeedService();
  final AnimalService _animalService = AnimalService();

  List<FeedNorm> _norms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNorms();
  }

  Future<void> _loadNorms() async {
    final norms = await _feedService.getNormsForAnimal(widget.animal);
    if (!mounted) return;
    setState(() {
      _norms = norms;
      _isLoading = false;
    });
  }

  Future<void> _delete() async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить животное?'),
        content: Text('«${widget.animal.name}» будет удалено безвозвратно.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Удалить', style: TextStyle(color: scheme.error))),
        ],
      ),
    );
    if (ok == true) {
      await _animalService.deleteAnimal(widget.animal.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
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
              const Spacer(),
              IconButton(
                onPressed: _delete,
                icon: Icon(Icons.delete_outline, color: scheme.error),
              ),
            ],
          ),
          const SizedBox(height: Light.space3),

          Center(
            child: Column(
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: Light.radiusXl,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: AnimalIcon(type: a.type, size: 88),
                ),
                const SizedBox(height: Light.space3),
                Text(a.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${a.type.displayName} · Активная карточка',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Light.space5),

          Row(
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'Возраст', value: '${a.ageMonths} мес.')),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'Вес', value: '${a.weight.toStringAsFixed(0)} кг')),
            ],
          ),
          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(Light.space4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: Light.radiusLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Тип продукции',
                          style: TextStyle(
                              fontSize: 11, color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 5),
                      Text(a.productivityType.displayName,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Продуктивность',
                          style: TextStyle(
                              fontSize: 11, color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 5),
                      Text(
                          '${a.productivity.toStringAsFixed(1)} ${a.productivityType.unit}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(Light.space4),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: Light.radiusLg,
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              children: [
                Text('Условия содержания',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 5),
                Text(a.conditions,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: Light.space5),

          Row(
            children: [
              Text('Норма корма',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('На день и год',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: Light.space3),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: Light.radiusLg,
                border: Border.all(color: scheme.outline),
              ),
              child: Column(
                children: _norms.map((n) => _FeedRow(norm: n)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Light.radiusLg,
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: scheme.onSurface)),
        ],
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  final FeedNorm norm;
  const _FeedRow({required this.norm});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(norm.feedType.displayName,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Корм',
                    style: TextStyle(
                        fontSize: 11, color: scheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style:
                        TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    children: [
                      const TextSpan(text: 'В день: '),
                      TextSpan(
                        text: '${norm.amountPerDay.toStringAsFixed(2)} кг',
                        style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style:
                        TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    children: [
                      const TextSpan(text: 'В год: '),
                      TextSpan(
                        text: '${norm.amountPerYear.toStringAsFixed(0)} кг',
                        style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}