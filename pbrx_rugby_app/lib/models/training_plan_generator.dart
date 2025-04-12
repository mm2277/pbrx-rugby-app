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

        try {
          final jsonMap = jsonDecode(cleanedJsonString);
          return TrainingPlan.fromJson(jsonMap);
        } catch (e) {
          print("Failed to parse plan JSON: $e");
          print("Raw JSON:\n$cleanedJsonString");
          return null;
        }
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
    final ability = profile.ability?.name ?? 'Unknown';

    return '''
You are a personal trainer specializing in rugby. Generate a realistic, progressive training plan in valid JSON format only for the following player:
-Name: $playerName
- Ability Level: $ability (e.g. beginner, intermediate, advanced)
- Position: $positionName (e.g. back, forward)
- Key Skills: $skillsList
- Season: $season
- Weeks: $weeks

Guidelines:
- Adapt to season: More sessions during in-season; fewer in off-season.
- Respect ability: Beginners get lighter load; advanced players can handle more.
-Tailor to position:
    Backs → more sprinting, agility, conditioning
    Forwards → more strength, power, tackling
- Train all skills listed in $skillsList sufficiently.

Requirements:
- JSON output must follow this structure:

{
  "weeksDuration": $weeks,
  "season": "$season",
  "dateCreated": "YYYY-MM-DD",
  "weeklyPlans": [
    {
      "days": [
        [
          {
            "durationMins": 60,
            "type": "Strength",
            "warmup": [
              {
                "name": "Jumping Jacks",
                "sets": 2,
                "reps": 20,
                "description": "Full-body warmup to raise heart rate."
              }
            ],
            "mainWorkout": [
              {
                "name": "Deadlift",
                "sets": 4,
                "reps": 6,
                "description": "Compound strength movement focused on posterior chain."
              }
            ]
          }
        ],
        [], [], [], [], [], []
      ]
    }
  ]
}
Additional Rules:
-Each week = 7 days, each day = list of 0 or more sessions
-Every session must include:
    durationMins: integer
    type: e.g., "Strength", "HIIT", "Power", "Conditioning"
    warmup: list of full exercise objects
    mainWorkout: list of full exercise objects
- Each exercise object must include:
    name, sets, reps, description
- No strings in place of objects in warmup or mainWorkout
- No markdown, no explanations — just clean, complete JSON
- Sessions should vary week to week
- Minimum 2 sessions per week
- Minimum of 3 exercises per session
 -If warmup is missing, default to { "name": "Light Jog", "sets": 1, "reps": 5, "description": "Easy-paced jog to increase core temperature." }

Important:
- Do not truncate or cut off JSON
- Always close all quotes, brackets, commas
- Do not generate any invalid or unterminated strings''';
  }
}
