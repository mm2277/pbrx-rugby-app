import 'package:pbrx_rugby_app/models/session.dart';

class Week {
  final List<List<Session>> days; // Always 7 days

  Week({required this.days});

  factory Week.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    List<List<Session>> parsedDays = [];

    if (rawDays == null) {
      parsedDays = List.generate(7, (_) => []);
    } else if (rawDays is List) {
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
      throw FormatException(
          "Unsupported format for 'days': ${rawDays.runtimeType}");
    }

    // Normalize to exactly 7 days
    if (parsedDays.length > 7) {
      parsedDays = parsedDays.sublist(0, 7); // trim extras
    } else if (parsedDays.length < 7) {
      parsedDays.addAll(List.generate(
          7 - parsedDays.length, (_) => [])); // pad with empty days
    }

    return Week(days: parsedDays);
  }
  Map<String, dynamic> toJson() => {
        'days': days.map((day) => day.map((s) => s.toJson()).toList()).toList(),
      };
}
