import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../themes/light.dart';
import '../../widgets/animal_icon.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final AnimalService _animalService = AnimalService();
  List<Animal> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    setState(() => _isLoading = true);
    final animals = await _animalService.getAnimals();
    if (!mounted) return;
    setState(() {
      _animals = animals;
      _isLoading = false;
    });
  }

  Future<void> _openForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnimalFormScreen()),
    );
    if (result == true && mounted) await _loadAnimals();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
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
                        child: Icon(Icons.chevron_left,
                            color: scheme.primary, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: Light.space5),
                  Text('Мои животные',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 7),
                  Text(
                      'Все питомцы и сельскохозяйственные животные в одном месте.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: Light.space5),

                  if (!_isLoading) _SummaryCard(count: _animals.length),

                  const SizedBox(height: Light.space5),
                  Row(
                    children: [
                      Text('Список животных',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text('${_animals.length} карточек',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: Light.space3),

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadAnimals,
                            color: scheme.primary,
                            child: _animals.isEmpty
                                ? ListView(
                                    children: [
                                      const SizedBox(height: 120),
                                      Center(
                                        child: Text(
                                          'Пока нет животных.\nДобавьте первое!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: _animals.length,
                                    itemBuilder: (context, index) =>
                                        _AnimalTile(
                                      animal: _animals[index],
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AnimalDetailScreen(
                                              animal: _animals[index],
                                            ),
                                          ),
                                        );
                                        if (mounted) await _loadAnimals();
                                      },
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  const _SummaryCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final colors = isDark
        ? const [Color(0xFF2A3322), Color(0xFF3A2A18)]
        : const [Color(0xFFDCE4C5), Color(0xFFEEE3CA)];

    return Container(
      padding: const EdgeInsets.all(Light.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        borderRadius: Light.radiusLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Всего на ферме',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB8CF7C)
                            : const Color(0xFF62674D))),
                const SizedBox(height: 3),
                Text('$count животных',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: Light.radiusMd,
            ),
            child: Icon(Icons.home_outlined,
                color: scheme.onPrimary, size: 26),
          ),
        ],
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;

  const _AnimalTile({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(Light.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(Light.radiusLarge),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Light.radiusLarge),
            border: Border.all(color: scheme.outline),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: Light.radiusMd,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: AnimalIcon(type: animal.type, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(animal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface)),
              const SizedBox(height: 2),
              Text(
                '${animal.type.displayName} · ${animal.weight.toStringAsFixed(0)} кг',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}