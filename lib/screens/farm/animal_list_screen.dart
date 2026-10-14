import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/animal.dart';
import '../../services/animal_service.dart';
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

  /// Pull-to-refresh: принудительно перечитываем из хранилища
  Future<void> _refreshAnimals() async {
    await _animalService.refresh();
    await _loadAnimals();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сбросить всех животных?'),
        content: const Text(
          'Это действие удалит всех животных из локального хранилища. '
          'Отменить его нельзя.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Сбросить',
              style: TextStyle(color: Light.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _animalService.clearAll();
      if (!mounted) return;
      await _loadAnimals();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все животные удалены')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Light.background,
      appBar: AppBar(
        title: const Text('Мои животные'),
        backgroundColor: Light.olive,
        foregroundColor: Light.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Сбросить всех животных (отладка)',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _animals.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refreshAnimals,
                  child: ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'Пока нет животных.\nДобавьте первое!',
                          textAlign: TextAlign.center,
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
                  onRefresh: _refreshAnimals,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _animals.length,
                    itemBuilder: (context, index) {
                      final animal = _animals[index];
                      return _buildAnimalCard(animal);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Light.olive,
        foregroundColor: Light.surface,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnimalFormScreen()),
          );
          if (result == true && mounted) {
            await _loadAnimals();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Light.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimalDetailScreen(animal: animal),
              ),
            );
            if (mounted) {
              await _loadAnimals();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  animal.type.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${animal.type.displayName} • ${animal.weight.toStringAsFixed(0)} кг',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Light.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Light.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}