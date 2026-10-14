import '../models/animal.dart';
import '../models/feed_norm.dart';
import '../models/farm_stats.dart';
import '../utils/feed_calculator.dart';

class FeedService {
  // Синглтон
  static final FeedService _instance = FeedService._internal();
  factory FeedService() => _instance;
  FeedService._internal();

  Future<List<FeedNorm>> getNormsForAnimal(Animal animal) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return FeedCalculator.normsForAnimal(animal);
  }

  Future<FarmStats> calculateFarmStats(List<Animal> animals) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (animals.isEmpty) {
      return FarmStats.empty();
    }

    double totalPerYear = 0;
    final breakdown = <FeedType, double>{};

    for (final animal in animals) {
      final norms = FeedCalculator.normsForAnimal(animal);
      for (final norm in norms) {
        totalPerYear += norm.amountPerYear;
        breakdown[norm.feedType] =
            (breakdown[norm.feedType] ?? 0) + norm.amountPerYear;
      }
    }

    return FarmStats(
      totalAnimals: animals.length,
      totalFeedPerYear: totalPerYear,
      feedBreakdown: breakdown,
    );
  }
}