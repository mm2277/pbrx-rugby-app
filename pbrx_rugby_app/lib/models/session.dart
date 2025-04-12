import 'package:pbrx_rugby_app/models/exercise.dart';
import 'package:pbrx_rugby_app/models/session_type.dart';

//Represents a single training session within a day
//Each session has a duration, type (e.g. Strength, HIIT), a list of warm-up exercises, and a list of main workout exercises.
class Session {
  final int durationMins; // Duration of the session in minutes 
  final SessionType type; // Type of session (e.g. Strength, HIIT, Power)
  final List<Exercise> warmup; // List of warm-up exercises
  final List<Exercise> mainWorkout; // List of main workout exercises

  Session({
    required this.durationMins,
    required this.type,
    required this.warmup,
    required this.mainWorkout,
  });

  /// Factory method to create a Session from a JSON map
  factory Session.fromJson(Map<String, dynamic> json) => Session(
        durationMins: json['durationMins'] ?? 0,
        type: SessionType.fromJson(
            json['type'] ?? 'Unknown'), // Fallback to Unknown 
        warmup: (json['warmup'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e))
                .toList() ??
            [], // Default to empty list if warmup is missing
        mainWorkout: (json['mainWorkout'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e))
                .toList() ??
            [], // Default to empty list if mainWorkout is missing 
      );

  // Converts the Session object into a JSON compatible map 
  Map<String, dynamic> toJson() => {
        'durationMins': durationMins,
        'type': type.toJson(), // Serialize SessionType enum
        'warmup': warmup.map((e) => e.toJson()).toList(),
        'mainWorkout': mainWorkout.map((e) => e.toJson()).toList(),
      };
}
