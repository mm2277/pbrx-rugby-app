import 'package:pbrx_rugby_app/models/exercise.dart';
import 'package:pbrx_rugby_app/models/session_type.dart';

class Session {
  final int durationMins;
  final SessionType type;
  final List<Exercise> warmup;
  final List<Exercise> mainWorkout;

  Session({
    required this.durationMins,
    required this.type,
    required this.warmup,
    required this.mainWorkout,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        durationMins: json['durationMins'] ?? 0,
        type: SessionType.fromJson(json['type'] ?? 'hiit'),
        warmup: (json['warmup'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e))
                .toList() ??
            [],
        mainWorkout: (json['mainWorkout'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'durationMins': durationMins,
        'type': type.toJson(),
        'warmup': warmup.map((e) => e.toJson()).toList(),
        'mainWorkout': mainWorkout.map((e) => e.toJson()).toList(),
      };
}
