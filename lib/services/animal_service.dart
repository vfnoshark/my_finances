import '../models/animal.dart';
import 'local_storage_service.dart';

class AnimalService {
  // Синглтон
  static final AnimalService _instance = AnimalService._internal();
  factory AnimalService() => _instance;
  AnimalService._internal();

  final LocalStorageService _storage = LocalStorageService();
  List<Animal>? _cache;

  Future<List<Animal>> _load() async {
    if (_cache != null) return _cache!;

    try {
      final raw = await _storage.loadAnimals();
      _cache = raw.map((e) {
        try {
          return Animal.fromJson(e);
        } catch (err) {
          print('Ошибка при чтении животного: $err, запись: $e');
          return null;
        }
      }).whereType<Animal>().toList();
    } catch (e) {
      print('Ошибка загрузки животных: $e');
      _cache = [];
    }

    return _cache!;
  }

  Future<void> _save() async {
    final raw = _cache!.map((a) => a.toJson()).toList();
    await _storage.saveAnimals(raw);
  }

  Future<List<Animal>> getAnimals() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = await _load();
    return List.unmodifiable(list);
  }

  Future<Animal> addAnimal(Animal animal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _load();
    _cache!.add(animal);
    await _save();
    return animal;
  }

  Future<Animal> updateAnimal(Animal animal) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _load();
    final index = _cache!.indexWhere((a) => a.id == animal.id);
    if (index == -1) {
      throw Exception('Животное не найдено');
    }
    _cache![index] = animal;
    await _save();
    return animal;
  }

  Future<void> deleteAnimal(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _load();
    _cache!.removeWhere((a) => a.id == id);
    await _save();
  }

  Future<Animal?> getAnimalById(String id) async {
    await _load();
    try {
      return _cache!.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Полный сброс (для отладки)
  Future<void> clearAll() async {
    _cache = [];
    await _storage.clearAnimals();
  }

  /// Принудительное перечитывание из хранилища.
  /// Используется только для pull-to-refresh, когда нужны данные
  /// из внешнего источника (например, после смены на другом устройстве).
  Future<void> refresh() async {
    _cache = null;
    await _load();
  }
}