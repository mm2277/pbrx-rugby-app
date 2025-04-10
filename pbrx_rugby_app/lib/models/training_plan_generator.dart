import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

class TrainingPlanGenerator {
  final String googleApiKey;

  TrainingPlanGenerator({required this.googleApiKey});

  Future<TrainingPlan?> generatePlanFromProfile(
    Profile profile, {
    required int weeksDuration,
    required String season,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$googleApiKey',
    );

    final prompt = _buildPromptFromProfile(profile, weeksDuration, season);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jsonString =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (jsonString != null) {
        final cleanedJsonString = jsonString
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .replaceAllMapped(RegExp(r'/\*.*?\*/', dotAll: true),
                (_) => '') // remove /* ... */ inline comments
            .split('\n')
            .where(
                (line) => !line.trim().startsWith('//')) // remove line comments
            .join('\n')
            .trim();

        final jsonMap = jsonDecode(cleanedJsonString);
        return TrainingPlan.fromJson(jsonMap);
      }
    }

    print("Gemini API Error: ${response.statusCode}");
    print(response.body);
    return null;
  }

  String _buildPromptFromProfile(Profile profile, int weeks, String season) {
    final positionName = profile.position?.name ?? 'Unknown';
    final skillsList = profile.skills?.map((s) => s.name).join(', ') ?? 'None';
    final playerName =
        profile.name?.isNotEmpty == true ? profile.name : 'Unnamed Player';

    return '''
You are a personal training for a rugby player, generate a training plan for a player with these attributes: 
- Name: $playerName
- Position: $positionName
- Skills: $skillsList
- Season: $season

The training plan must be  $weeks weeks long and follow this JSON structure:
{
  "weeksDuration": $weeks,
  "season": $season,
  "dateCreated": (replace with today's date)
  "weeklyPlans": [
    {
      "days": [
        [
          {
            "durationMins": (estimate the duration for each session),
            "type": "hiit",
            "warmup": [
              { "name": "Jumping Jacks", "reps": 20, "sets": 2 }
            ],
            "mainWorkout": [
              { "name": "Burpees", "reps": 10, "sets": 3 }
            ]
          }
        ],
        [], [], [], [], [], []
      ]
    }
  ]
}

Replace and add things where necessary to fill out the training plan.

Other Requirements:
- dateCreated: in ISO 8601 format (e.g. "2024-04-10") must be today's date
- weeklyPlans: list of weeks
- Each week has 7 days, each day is a list of 0 or more sessions
- Each session is an object that must have:
  - durationMins: integer
  - type: one of "hiit", "cardio", "weights", etc.
  - warmup: list of exercise objects
  - mainWorkout: list of exercise objects

Each exercise must be a full object:
{
  "name": "Push Ups",
  "sets": 3,
  "reps": 12
}

Do NOT use strings in warmup or mainWorkout. No explanations or markdown. Respond ONLY with valid, clean JSON.
''';
  }
}
