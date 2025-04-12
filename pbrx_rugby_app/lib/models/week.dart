import 'package:pbrx_rugby_app/models/session.dart';

//represents a single training week consisting of 7 days.
//each day contains a list of `Session` objects (e.g., warmup, workout).
class Week {
  final List<List<Session>> days; // always 7 days

  Week({required this.days});

  //Factory constructor to create a Week from JSON.
  factory Week.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['days'];
    List<List<Session>> parsedDays = [];

    //handle case where 'days' is missing or null
    if (rawDays == null) {
      parsedDays = List.generate(7, (_) => []); 
    } 
    // Case 1: days is a List 
    else if (rawDays is List) {
      parsedDays = rawDays.map<List<Session>>((day) {
        if (day is List) {
          // Each day is a list of session maps
          return day.map<Session>((s) => Session.fromJson(s)).toList();
        } else if (day is Map<String, dynamic>) {
          // Single session in the day
          return [Session.fromJson(day)];
        } else {
          return []; 
        }
      }).toList();
    } 
    // Case 2: days is a Map 
    else if (rawDays is Map) {
      for (int i = 0; i < 7; i++) {
        final dayData = rawDays[i.toString()];
        if (dayData is List) {
          // Day contains a list of session maps
          parsedDays.add(dayData.map<Session>((s) => Session.fromJson(s)).toList());
        } else if (dayData is Map<String, dynamic>) {
          // Single session in a day
          parsedDays.add([Session.fromJson(dayData)]);
        } else {
          parsedDays.add([]); // no sessions for the day.
        }
      }
    } 
    //unsupported structure for 'days'
    else {
      throw FormatException("Unsupported format for 'days': ${rawDays.runtimeType}");
    }

    //exactly 7 days 
    if (parsedDays.length > 7) {
      parsedDays = parsedDays.sublist(0, 7); //trim extra entries
    } else if (parsedDays.length < 7) {
      parsedDays.addAll(List.generate(7 - parsedDays.length, (_) => [])); //pad with empty days
    }

    return Week(days: parsedDays);
  }

  //converts the Week object back to JSON
  Map<String, dynamic> toJson() => {
        'days': days.map((day) => day.map((s) => s.toJson()).toList()).toList(),
      };
}
