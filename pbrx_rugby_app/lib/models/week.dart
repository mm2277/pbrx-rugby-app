import 'package:pbrx_rugby_app/models/session.dart';

class Week {
  final List<List<Session>> days; // 7 days, each may have 0+ sessions

  Week({required this.days}) : assert(days.length == 7);

  factory Week.fromJson(Map<String, dynamic> json) => Week(
        days: (json['days'] as List)
            .map((day) => (day as List)
                .map((session) => Session.fromJson(session))
                .toList())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'days': days.map((day) => day.map((s) => s.toJson()).toList()).toList(),
      };
}
