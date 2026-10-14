import 'feed_norm.dart';

/// Общая статистика по ферме
class FarmStats {
  final int totalAnimals;
  final double totalFeedPerYear;
  final Map<FeedType, double> feedBreakdown;

  FarmStats({
    required this.totalAnimals,
    required this.totalFeedPerYear,
    required this.feedBreakdown,
  });

  factory FarmStats.empty() {
    return FarmStats(
      totalAnimals: 0,
      totalFeedPerYear: 0,
      feedBreakdown: {},
    );
  }

  factory FarmStats.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['feedBreakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <FeedType, double>{};
    breakdownJson.forEach((key, value) {
      final type = FeedType.values.firstWhere(
        (e) => e.name == key,
        orElse: () => FeedType.hay,
      );
      breakdown[type] = (value as num).toDouble();
    });

    return FarmStats(
      totalAnimals: json['totalAnimals'] as int,
      totalFeedPerYear: (json['totalFeedPerYear'] as num).toDouble(),
      feedBreakdown: breakdown,
    );
  }

  Map<String, dynamic> toJson() {
    final breakdownJson = <String, double>{};
    feedBreakdown.forEach((key, value) {
      breakdownJson[key.name] = value;
    });

    return {
      'totalAnimals': totalAnimals,
      'totalFeedPerYear': totalFeedPerYear,
      'feedBreakdown': breakdownJson,
    };
  }
}