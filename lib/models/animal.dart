/// Тип животного
enum AnimalType {
  cattle,   // КРС
  sheep,    // Овцы
  goat,     // Козы
  pig,      // Свиньи
  poultry,  // Птица
}

extension AnimalTypeExtension on AnimalType {
  String get displayName {
    switch (this) {
      case AnimalType.cattle:
        return 'КРС';
      case AnimalType.sheep:
        return 'Овцы';
      case AnimalType.goat:
        return 'Козы';
      case AnimalType.pig:
        return 'Свиньи';
      case AnimalType.poultry:
        return 'Птица';
    }
  }

  String get icon {
    switch (this) {
      case AnimalType.cattle:
        return '🐄';
      case AnimalType.sheep:
        return '🐑';
      case AnimalType.goat:
        return '🐐';
      case AnimalType.pig:
        return '🐖';
      case AnimalType.poultry:
        return '🐔';
    }
  }

  /// Список возможных типов продуктивности для этого животного
  List<ProductivityType> get productivityOptions {
    switch (this) {
      case AnimalType.cattle:
        return [ProductivityType.milk, ProductivityType.meat];
      case AnimalType.sheep:
        return [ProductivityType.wool, ProductivityType.meat];
      case AnimalType.goat:
        return [ProductivityType.milk, ProductivityType.meat];
      case AnimalType.pig:
        return [ProductivityType.meat];
      case AnimalType.poultry:
        return [ProductivityType.eggs, ProductivityType.meat];
    }
  }

  /// Условия содержания по умолчанию
  List<String> get conditionsOptions {
    switch (this) {
      case AnimalType.cattle:
        return ['Стойло', 'Пастбище', 'Стойло + пастбище'];
      case AnimalType.sheep:
      case AnimalType.goat:
        return ['Пастбище', 'Загон', 'Пастбище + загон'];
      case AnimalType.pig:
        return ['Свинарник', 'Выгул', 'Свинарник + выгул'];
      case AnimalType.poultry:
        return ['Курятник', 'Вольер', 'Курятник + вольер'];
    }
  }
}

/// Тип продуктивности
enum ProductivityType {
  milk,   // Молочная
  meat,   // Мясная
  wool,   // Шерстяная
  eggs,   // Яйценоскость
}

extension ProductivityTypeExtension on ProductivityType {
  String get displayName {
    switch (this) {
      case ProductivityType.milk:
        return 'Молочная';
      case ProductivityType.meat:
        return 'Мясная';
      case ProductivityType.wool:
        return 'Шерстяная';
      case ProductivityType.eggs:
        return 'Яйценоскость';
    }
  }

  /// Единица измерения продуктивности
  String get unit {
    switch (this) {
      case ProductivityType.milk:
        return 'л/день';
      case ProductivityType.meat:
        return 'кг/день';
      case ProductivityType.wool:
        return 'кг/год';
      case ProductivityType.eggs:
        return 'шт/день';
    }
  }
}

/// Модель животного
class Animal {
  final String id;
  final AnimalType type;
  final String name;
  final int ageMonths;
  final double weight;
  final ProductivityType productivityType;
  final double productivity;
  final String conditions;

  Animal({
    required this.id,
    required this.type,
    required this.name,
    required this.ageMonths,
    required this.weight,
    required this.productivityType,
    required this.productivity,
    required this.conditions,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      type: AnimalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnimalType.cattle,
      ),
      name: json['name'] as String,
      ageMonths: json['ageMonths'] as int,
      weight: (json['weight'] as num).toDouble(),
      productivityType: ProductivityType.values.firstWhere(
        (e) => e.name == json['productivityType'],
        orElse: () => ProductivityType.milk,
      ),
      productivity: (json['productivity'] as num).toDouble(),
      conditions: json['conditions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'ageMonths': ageMonths,
      'weight': weight,
      'productivityType': productivityType.name,
      'productivity': productivity,
      'conditions': conditions,
    };
  }

  Animal copyWith({
    String? id,
    AnimalType? type,
    String? name,
    int? ageMonths,
    double? weight,
    ProductivityType? productivityType,
    double? productivity,
    String? conditions,
  }) {
    return Animal(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      ageMonths: ageMonths ?? this.ageMonths,
      weight: weight ?? this.weight,
      productivityType: productivityType ?? this.productivityType,
      productivity: productivity ?? this.productivity,
      conditions: conditions ?? this.conditions,
    );
  }
}