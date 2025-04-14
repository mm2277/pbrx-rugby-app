import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

//service class that interacts with Google Gemini API to generate a training plan based on a player's profile
class TrainingPlanGenerator {
  final String googleApiKey;

  TrainingPlanGenerator({required this.googleApiKey});

  ///sends a POST request to Gemini API with a generated prompt from profile data.
  // parses and returns a [TrainingPlan] if the response is valid JSON
  Future<TrainingPlan?> generatePlanFromProfile(
    Profile profile, {
    required int weeksDuration,
    required String season,
  }) async {
    //Build request URL with Gemini endpoint
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$googleApiKey',
    );

    //Generate prompt using profile data
    final prompt = _buildPromptFromProfile(profile, weeksDuration, season);

    // make http POST  request to Gemini
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
          "maxOutputTokens": 2048 // max output size for Gemini response
        }
      }),
    );

    //handle successful response
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      //Extract text from response
      final jsonString =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (jsonString != null) {
        //Clean Gemini-generated JSON string
        final cleanedJsonString = jsonString
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .replaceAllMapped(RegExp(r'/\*.*?\*/', dotAll: true), (_) => '')
            .split('\n')
            .where((line) => !line.trim().startsWith('//'))
            .join('\n')
            .trim();

        try {
          //Attempt to parse the cleaned JSON string into a Dart object
          final jsonMap = jsonDecode(cleanedJsonString);
          return TrainingPlan.fromJson(jsonMap);
        } catch (e) {
          //log parsing failure and raw output
          print("Failed to parse plan JSON: $e");
          print("Raw JSON:\n$cleanedJsonString");
          return null;
        }
      }
    }

    // Log any API failure
    print("Gemini API Error: ${response.statusCode}");
    print(response.body);
    return null;
  }

  //Builds a detailed text prompt that guides Gemini to generate structured JSON output.
  //The prompt includes player details, structure requirements, and strict formatting rules
  String _buildPromptFromProfile(Profile profile, int weeks, String season) {
    final positionName = profile.position?.name ?? 'Unknown';
    final skillsList = profile.skills?.map((s) => s.name).join(', ') ?? 'None';
    final playerName =
        profile.name?.isNotEmpty == true ? profile.name : 'Unnamed Player';
    final ability = profile.ability?.name ?? 'Unknown';

    return '''
You are a high-performance rugby trainer and strength & conditioning coach.

Generate a personalized and progressive training plan in **valid JSON** format for the following rugby player:

- Name: $playerName  
- Ability Level: $ability (e.g. beginner, intermediate, advanced)  
- Position: $positionName (e.g. back, forward)  
- Key Skills: $skillsList (comma-separated list, e.g. "kicking, tackling")  
- Season Phase: $season (e.g. "in-season", "out-season")  
- Duration: $weeks weeks  

Guidelines:
- **Adapt to Season Phase:**  
  - In-season: Higher frequency, shorter sessions, recovery-conscious  
  - Out-season: Progressive load, intense conditioning, tactical readiness  

- **Respect Ability Level:**  
  - Beginner: Emphasize technique, mobility, and safe progressions  
  - Intermediate: Increase complexity, intensity, and sport-specificity  
  - Advanced: High intensity, targeted skill refinement, and performance focus  

- **Tailor to Position:**  
  - Backs: Sprinting, agility, footwork, conditioning  
  - Forwards: Strength, power, tackling, scrummaging movements  

- **Train Skills from Key Skills List:**  
  - Include specific drills or movements that build these skills directly or supportively

📋 Requirements:
- Return **only** valid JSON in this structure:

```json
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
- Each week = 7 days, each day = list of 0 or more sessions
- Every session must include:
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
- If warmup is missing, default to:
  {
    "name": "Light Jog",
    "sets": 1,
    "reps": 5,
    "description": "Easy-paced jog to increase core temperature."
  }

Important:
- Do not truncate or cut off JSON
- Always close all quotes, brackets, commas
- Do not generate any invalid or unterminated strings
''';
  }
}
