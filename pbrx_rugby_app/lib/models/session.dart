import 'package:pbrx_rugby_app/models/exercise.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

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
        durationMins: json['durationMins'],
        type: SessionType.fromJson(json['type']),
        warmup:
            (json['warmup'] as List).map((e) => Exercise.fromJson(e)).toList(),
        mainWorkout: (json['mainWorkout'] as List)
            .map((e) => Exercise.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'durationMins': durationMins,
        'type': type.toJson(),
        'warmup': warmup.map((e) => e.toJson()).toList(),
        'mainWorkout': mainWorkout.map((e) => e.toJson()).toList(),
      };
}
