import 'package:pbrx_rugby_app/models/week.dart';

enum Season {
  inSeason,
  outSeason;

  String toJson() => name;

  static Season fromJson(String json) =>
      Season.values.firstWhere((e) => e.name == json);
}

enum SessionType {
  hiit,
  cardio,
  weights,
  mobility,
  recovery;

  String toJson() => name;

  static SessionType fromJson(String json) =>
      SessionType.values.firstWhere((e) => e.name == json);
}

class TrainingPlan {
  final int weeksDuration;
  final Season season;
  final List<Week> weeklyPlans;
  final DateTime dateCreated;

  TrainingPlan({
    required this.weeksDuration,
    required this.season,
    required this.weeklyPlans,
    required this.dateCreated,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) => TrainingPlan(
        weeksDuration: json['weeksDuration'],
        season: Season.fromJson(json['season']),
        weeklyPlans: (json['weeklyPlans'] as List)
            .map((week) => Week.fromJson(week))
            .toList(),
        dateCreated: DateTime.parse(json['dateCreated']),
      );

  Map<String, dynamic> toJson() => {
        'weeksDuration': weeksDuration,
        'season': season.toJson(),
        'weeklyPlans': weeklyPlans.map((w) => w.toJson()).toList(),
        'dateCreated': dateCreated.toIso8601String(),
      };
}