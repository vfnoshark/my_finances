import '../models/animal.dart';
import '../models/feed_norm.dart';

class FeedCalculator {
  static double dailyNorm(Animal animal) {
    switch (animal.type) {
      case AnimalType.cattle:
        // Если молочная — учитываем удой
        if (animal.productivityType == ProductivityType.milk) {
          return animal.weight * 0.02 + animal.productivity * 0.5;
        }
        // Мясная — только вес
        return animal.weight * 0.025;

      case AnimalType.sheep:
        return animal.weight * 0.03;

      case AnimalType.goat:
        return animal.weight * 0.03;

      case AnimalType.pig:
        return animal.weight * 0.04;

      case AnimalType.poultry:
        return animal.weight * 0.10;
    }
  }

  static double yearlyNorm(Animal animal) {
    return dailyNorm(animal) * 365;
  }

  static Map<FeedType, double> dailyBreakdown(Animal animal) {
    final total = dailyNorm(animal);

    switch (animal.type) {
      case AnimalType.cattle:
        return {
          FeedType.hay: total * 0.5,
          FeedType.silage: total * 0.3,
          FeedType.compound: total * 0.2,
        };
      case AnimalType.sheep:
      case AnimalType.goat:
        return {
          FeedType.hay: total * 0.6,
          FeedType.pasture: total * 0.4,
        };
      case AnimalType.pig:
        return {
          FeedType.compound: total * 0.7,
          FeedType.grain: total * 0.3,
        };
      case AnimalType.poultry:
        return {
          FeedType.grain: total * 0.6,
          FeedType.compound: total * 0.4,
        };
    }
  }

  static List<FeedNorm> normsForAnimal(Animal animal) {
    final breakdown = dailyBreakdown(animal);
    final result = <FeedNorm>[];

    breakdown.forEach((feedType, amountPerDay) {
      result.add(FeedNorm(
        animalId: animal.id,
        feedType: feedType,
        amountPerDay: amountPerDay,
        amountPerYear: amountPerDay * 365,
      ));
    });

    return result;
  }
}