import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../themes/light.dart';
import '../../widgets/animal_icon.dart';
import '../../widgets/app_scaffold.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalService = AnimalService();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _yieldController;

  AnimalType _type = AnimalType.cattle;
  ProductivityType _productivity = ProductivityType.milk;
  String? _conditions;
  bool _saving = false;

  bool get _isEditing => widget.animal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameController = TextEditingController(text: a?.name ?? '');
    _ageController = TextEditingController(text: a?.ageMonths.toString() ?? '');
    _weightController = TextEditingController(text: a?.weight.toString() ?? '');
    _yieldController =
        TextEditingController(text: a?.productivity.toString() ?? '');
    _type = a?.type ?? AnimalType.cattle;
    _productivity = a?.productivityType ?? _type.productivityOptions.first;

    if (a != null && a.conditions.isNotEmpty) {
      _conditions = a.conditions;
    } else {
      _conditions = _type.conditionsOptions.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_conditions == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите условия содержания')),
      );
      return;
    }

    setState(() => _saving = true);

    final animal = Animal(
      id: widget.animal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      name: _nameController.text.trim(),
      ageMonths: int.parse(_ageController.text.trim()),
      weight: double.parse(_weightController.text.trim().replaceAll(',', '.')),
      productivityType: _productivity,
      productivity:
          double.tryParse(_yieldController.text.trim().replaceAll(',', '.')) ??
              0,
      conditions: _conditions!,
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
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      withScroll: true,
      child: Form(
        key: _formKey,
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
                Text('МОЯ ФЕРМА / ЖИВОТНЫЕ',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: Light.space4),
            Text(_isEditing ? 'Редактировать' : 'Добавить животное',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 7),
            Text(
                'Заполните карточку, чтобы вести учёт животных и их продуктивности.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: Light.space5),

            Text('Выберите тип животного',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary)),
            const SizedBox(height: 10),
            _typeSelector(),
            const SizedBox(height: Light.space5),

            _field(
              label: 'Кличка или номер',
              controller: _nameController,
              hint: 'Например, Белянка или № 024',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
            ),
            const SizedBox(height: Light.space3),

            Row(
              children: [
                Expanded(
                  child: _field(
                    label: 'Возраст, месяцев',
                    controller: _ageController,
                    hint: '12',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Введите возраст';
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Некорректно';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _field(
                    label: 'Вес, кг',
                    controller: _weightController,
                    hint: '85',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите вес';
                      final n =
                          double.tryParse(v.trim().replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Некорректно';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Light.space3),

            _dropdown<ProductivityType>(
              label: 'Тип продукции',
              value: _productivity,
              items: _type.productivityOptions
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _productivity = v);
              },
            ),
            const SizedBox(height: Light.space3),

            _field(
              label: 'Продуктивность',
              controller: _yieldController,
              hint: 'Например, ${_productivity.unit}',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: Light.space3),

            _dropdown<String>(
              label: 'Условия содержания',
              value: _conditions,
              items: _type.conditionsOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _conditions = v),
            ),
            const SizedBox(height: Light.space5),

            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    child: Text(
                        _isEditing ? 'Сохранить' : 'Добавить животное  →'),
                  ),
            const SizedBox(height: Light.space5),
            Center(
              child: Text('Каждое животное — часть вашей фермы',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    final scheme = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.72,
      children: AnimalType.values.map((type) {
        final selected = _type == type;
        return GestureDetector(
          onTap: () => setState(() {
            _type = type;
            _productivity = type.productivityOptions.first;
            _conditions = type.conditionsOptions.first;
          }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF94A85E)
                              : const Color(0xFF6C7545))
                          : scheme.primary,
                      borderRadius: BorderRadius.circular(17),
                      border: selected
                          ? Border.all(
                              color: const Color(0xFFD6C29C), width: 3)
                          : null,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: AnimalIcon(type: type, size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                type.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant)),
        ),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: Light.radiusMd,
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Light.radiusMd,
              borderSide: BorderSide(color: scheme.outline),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant)),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: Light.radiusMd,
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Light.radiusMd,
              borderSide: BorderSide(color: scheme.outline),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          ),
        ),
      ],
    );
  }
}