import 'package:pbrx_rugby_app/models/week.dart';

/// Enum representing the training season type
enum Season {
  inSeason,
  outSeason;

  /// Converts the enum to a JSON-friendly string (e.g., "inSeason")
  String toJson() => name;

  /// Converts a string back to a Season enum value
  static Season fromJson(String json) =>
      Season.values.firstWhere((e) => e.name == json);
}

// Represents a complete training plan made up of multiple weeks.
class TrainingPlan {
  final int weeksDuration;           //Total duration of the plan in weeks
  final Season season;               //Whether the plan is for in-season or off-season
  final List<Week> weeklyPlans;      //List of Week objects (each with 7 days)
  final DateTime dateCreated;        //Date when the plan was created
  bool? completed;                   //whether the plan has been marked as completed

  TrainingPlan({
    required this.weeksDuration,
    required this.season,
    required this.weeklyPlans,
    required this.dateCreated,
    this.completed,
  });

  //getter to safely access completion status, defaults to false if null.
  bool get isCompleted => completed ?? false;

  //setter to update the completion status
  void setCompleted(bool value) {
    completed = value;
  }

  //Factory constructor to create a TrainingPlan object from JSON.
  factory TrainingPlan.fromJson(Map<String, dynamic> json) => TrainingPlan(
        weeksDuration: json['weeksDuration'],
        season: Season.fromJson(json['season']),
        weeklyPlans: (json['weeklyPlans'] as List)
            .map((week) => Week.fromJson(week))
            .toList(),
        dateCreated: DateTime.parse(json['dateCreated']),
        completed: json['completed'] as bool?, //optional
      );

  //converts this TrainingPlan to a JSON compatible map
  Map<String, dynamic> toJson() => {
        'weeksDuration': weeksDuration,
        'season': season.toJson(),
        'weeklyPlans': weeklyPlans.map((w) => w.toJson()).toList(),
        'dateCreated': dateCreated.toIso8601String(),
        'completed': completed ?? false, // ensure it's always boolean in JSON
      };
}
