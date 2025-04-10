import 'package:pbrx_rugby_app/models/session.dart';

class Week {
  final List<List<Session>> days; // 7 days, each may have 0+ sessions

  Week({required this.days}) : assert(days.length == 7);

  factory Week.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    List<List<Session>> parsedDays = [];

    if (rawDays is List) {
      // Proper list format
      parsedDays = rawDays.map<List<Session>>((day) {
        if (day is List) {
          return day.map<Session>((s) => Session.fromJson(s)).toList();
        } else if (day is Map<String, dynamic>) {
          return [Session.fromJson(day)];
        } else {
          return [];
        }
      }).toList();
    } else if (rawDays is Map) {
      // Handle dictionary-formatted days like { "0": [...], "1": [...], ... }
      for (int i = 0; i < 7; i++) {
        final dayData = rawDays[i.toString()];
        if (dayData is List) {
          parsedDays
              .add(dayData.map<Session>((s) => Session.fromJson(s)).toList());
        } else if (dayData is Map<String, dynamic>) {
          parsedDays.add([Session.fromJson(dayData)]);
        } else {
          parsedDays.add([]);
        }
      }
    } else {
      throw FormatException("Unsupported format for 'days'");
    }

    // Ensure we always have 7 days
    while (parsedDays.length < 7) {
      parsedDays.add([]);
    }

    return Week(days: parsedDays);
  }

  Map<String, dynamic> toJson() => {
        'days': days.map((day) => day.map((s) => s.toJson()).toList()).toList(),
      };
}
