import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/animal.dart';
import '../../models/feed_norm.dart';
import '../../services/animal_service.dart';
import '../../services/feed_service.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;

  const AnimalDetailScreen({
    super.key,
    required this.animal,
  });

  @override
  State<AnimalDetailScreen> createState() =>
      _AnimalDetailScreenState();
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
    final norms =
        await _feedService.getNormsForAnimal(widget.animal);

    if (!mounted) return;

    setState(() {
      _norms = norms;
      _isLoading = false;
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Animal animal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить животное?'),
        content: Text(
          '«${animal.name}» будет удалено безвозвратно.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Light.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _animalService.deleteAnimal(animal.id);

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка животного'),
        actions: [
          IconButton(
            tooltip: 'Удалить животное',
            icon: const Icon(Icons.delete_outline),
            color: Light.error,
            onPressed: () =>
                _confirmDelete(context, animal),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Light.space5,
                Light.space2,
                Light.space5,
                Light.space8,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    Light.space5,
                  ),
                  decoration: Light.heroDecoration,
                  child: Column(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        alignment: Alignment.center,
                        decoration: Light.oliveCardDecoration,
                        child: Text(
                          animal.type.icon,
                          style: const TextStyle(
                            fontSize: 58,
                          ),
                        ),
                      ),
                      const SizedBox(height: Light.space3),
                      Text(
                        animal.name,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge,
                      ),
                      const SizedBox(height: Light.space1),
                      Text(
                        animal.type.displayName,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Light.oliveDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Light.space5),
                Text(
                  'Характеристики',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: Light.space3),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Возраст',
                        '${animal.ageMonths} мес.',
                        Icons.cake_outlined,
                      ),
                    ),
                    const SizedBox(width: Light.space3),
                    Expanded(
                      child: _buildInfoCard(
                        'Вес',
                        '${animal.weight.toStringAsFixed(0)} кг',
                        Icons.monitor_weight_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Light.space3),
                _buildInfoRow(
                  'Продуктивность',
                  animal.productivity.toStringAsFixed(1),
                ),
                _buildInfoRow(
                  'Условия содержания',
                  animal.conditions,
                ),
                const SizedBox(height: Light.space5),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Норма корма',
                      style: textTheme.titleLarge,
                    ),
                    Text(
                      '${_norms.length} позиций',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: Light.space3),
                if (_norms.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(
                      Light.space5,
                    ),
                    decoration: Light.cardDecoration,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.grass_outlined,
                          size: 34,
                          color: Light.oliveSoft,
                        ),
                        const SizedBox(height: Light.space2),
                        Text(
                          'Нормы кормления пока не добавлены',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Light.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._norms.map((norm) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: Light.space3,
                      ),
                      padding: const EdgeInsets.all(
                        Light.space4,
                      ),
                      decoration: Light.cardDecoration,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Light.surfaceMuted,
                                  borderRadius: Light.radiusMd,
                                ),
                                child: const Icon(
                                  Icons.grass_outlined,
                                  color: Light.olive,
                                ),
                              ),
                              const SizedBox(
                                width: Light.space3,
                              ),
                              Expanded(
                                child: Text(
                                  norm.feedType.displayName,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Light.space4),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeedValue(
                                  'В день',
                                  '${norm.amountPerDay.toStringAsFixed(2)} кг',
                                ),
                              ),
                              const SizedBox(
                                width: Light.space2,
                              ),
                              Expanded(
                                child: _buildFeedValue(
                                  'В год',
                                  '${norm.amountPerYear.toStringAsFixed(0)} кг',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Light.space4),
      decoration: Light.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Light.olive, size: 22),
          const SizedBox(height: Light.space3),
          Text(label, style: textTheme.bodySmall),
          const SizedBox(height: Light.space1),
          Text(
            value,
            style: textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Light.space3),
      padding: const EdgeInsets.all(Light.space4),
      decoration: Light.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Light.textMuted,
              ),
            ),
          ),
          const SizedBox(width: Light.space3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedValue(String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Light.space3),
      decoration: BoxDecoration(
        color: Light.surfaceMuted,
        borderRadius: Light.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall),
          const SizedBox(height: Light.space1),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: Light.oliveDark,
            ),
          ),
        ],
      ),
    );
  }
}
