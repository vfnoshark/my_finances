import 'package:flutter/material.dart';
import '../../themes/Light.dart';
import '../../models/animal.dart';
import '../../services/animal_service.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;

  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AnimalService _animalService = AnimalService();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _productivityController;

  AnimalType _selectedType = AnimalType.cattle;
  ProductivityType _selectedProductivity = ProductivityType.milk;
  String _selectedConditions = '';
  bool _isSaving = false;

  bool get _isEditing => widget.animal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;

    _nameController = TextEditingController(text: a?.name ?? '');
    _ageController = TextEditingController(text: a?.ageMonths.toString() ?? '');
    _weightController = TextEditingController(text: a?.weight.toString() ?? '');
    _productivityController =
        TextEditingController(text: a?.productivity.toString() ?? '');

    if (a != null) {
      _selectedType = a.type;
      _selectedProductivity = a.productivityType;
      _selectedConditions = a.conditions;
    } else {
      _selectedType = AnimalType.cattle;
      _selectedProductivity = _selectedType.productivityOptions.first;
      _selectedConditions = _selectedType.conditionsOptions.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _productivityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final animal = Animal(
      id: widget.animal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      name: _nameController.text.trim(),
      ageMonths: int.parse(_ageController.text.trim()),
      weight: double.parse(_weightController.text.trim().replaceAll(',', '.')),
      productivityType: _selectedProductivity,
      productivity: double.tryParse(
            _productivityController.text.trim().replaceAll(',', '.'),
          ) ??
          0,
      conditions: _selectedConditions,
    );

    try {
      if (_isEditing) {
        await _animalService.updateAnimal(animal);
      } else {
        await _animalService.addAnimal(animal);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Light.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Добавить животное'),
        backgroundColor: Light.olive,
        foregroundColor: Light.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Тип животного
            const Text(
              'Тип животного',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Имя
            _buildTextField(
              controller: _nameController,
              label: 'Имя или номер',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
            ),
            const SizedBox(height: 16),

            // Возраст
            _buildTextField(
              controller: _ageController,
              label: 'Возраст (месяцев)',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите возраст';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Некорректное число';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Вес
            _buildTextField(
              controller: _weightController,
              label: 'Вес (кг)',
              icon: Icons.scale_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите вес';
                final n = double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Некорректное число';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Продуктивность (тип)
            const Text(
              'Тип продуктивности',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProductivityType>(
              value: _selectedProductivity,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.trending_up),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Light.surface,
              ),
              items: _selectedType.productivityOptions.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedProductivity = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Продуктивность (значение)
            _buildTextField(
              controller: _productivityController,
              label: 'Продуктивность',
              hint: _selectedProductivity.unit,
              icon: Icons.numbers,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null || n < 0) return 'Некорректное число';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Условия содержания
            const Text(
              'Условия содержания',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedConditions.isEmpty ? null : _selectedConditions,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Light.surface,
              ),
              items: _selectedType.conditionsOptions.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedConditions = value);
              },
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Выберите условия' : null,
            ),
            const SizedBox(height: 32),

            // Кнопка сохранения
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Light.olive,
                  foregroundColor: Light.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Light.surface,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Сохранить' : 'Добавить',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AnimalType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
              // Сбрасываем продуктивность и условия под новый тип
              _selectedProductivity = type.productivityOptions.first;
              _selectedConditions = type.conditionsOptions.first;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Light.olive : Light.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Light.olive : Light.outline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Light.surface : Light.text,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Light.surface,
      ),
    );
  }
}