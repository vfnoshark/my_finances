/// Тип корма
enum FeedType {
  hay,      // Сено
  silage,   // Силос
  compound, // Комбикорм
  grain,    // Зерно
  pasture,  // Пастбище
}

extension FeedTypeExtension on FeedType {
  String get displayName {
    switch (this) {
      case FeedType.hay:
        return 'Сено';
      case FeedType.silage:
        return 'Силос';
      case FeedType.compound:
        return 'Комбикорм';
      case FeedType.grain:
        return 'Зерно';
      case FeedType.pasture:
        return 'Пастбище';
    }
  }

  String get unit => 'кг';
}

/// Норма корма для одного животного
class FeedNorm {
  final String animalId;
  final FeedType feedType;
  final double amountPerDay;
  final double amountPerYear;

  FeedNorm({
    required this.animalId,
    required this.feedType,
    required this.amountPerDay,
    required this.amountPerYear,
  });

  factory FeedNorm.fromJson(Map<String, dynamic> json) {
    return FeedNorm(
      animalId: json['animalId'] as String,
      feedType: FeedType.values.firstWhere(
        (e) => e.name == json['feedType'],
        orElse: () => FeedType.hay,
      ),
      amountPerDay: (json['amountPerDay'] as num).toDouble(),
      amountPerYear: (json['amountPerYear'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'feedType': feedType.name,
      'amountPerDay': amountPerDay,
      'amountPerYear': amountPerYear,
    };
  }
}