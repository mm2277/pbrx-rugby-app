import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

class TrainingPlanGenerator {
  final String openAiKey;

  TrainingPlanGenerator({required this.openAiKey});

  Future<TrainingPlan?> generatePlanFromProfile(Profile profile) async {
    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    final prompt = _buildPromptFromProfile(profile);

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $openAiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a sports performance coach generating structured rugby training plans."
          },
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jsonString = data["choices"][0]["message"]["content"];
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return TrainingPlan.fromJson(jsonMap);
    } else {
      print("OpenAI error: ${response.statusCode}, ${response.body}");
      return null;
    }
  }

  String _buildPromptFromProfile(Profile profile) {
    final positionName = profile.position?.name ?? 'Unknown';
    final skillsList = profile.skills?.map((s) => s.name).join(', ') ?? 'None';
    final playerName =
        profile.name?.isNotEmpty == true ? profile.name : 'Unnamed Player';

    return '''
Generate a JSON training plan for a rugby player with the following profile:
Name: $playerName
Position: $positionName
Skills: $skillsList

Format the JSON to match this structure:
{
  "weeksDuration": int,
  "season": "inSeason" or "outSeason",
  "dateCreated": "ISO 8601 format",
  "weeklyPlans": [
    {
      "days": [
        [ { "durationMins": 45, "type": "hiit", "warmup": [...], "mainWorkout": [...] } ],
        [],
        ...
      ]
    }
  ]
}
''';
  }
}
