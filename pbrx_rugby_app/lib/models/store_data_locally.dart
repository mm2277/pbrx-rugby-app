import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

class StoreDataLocally {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _profileFile async {
    final path = await _localPath;
    return File('$path/profile.txt');
  }

  Future<File> writeProfile(Profile profile) async {
    final file = await _profileFile;

    // Write the file
    return file.writeAsString(profile.toString());
  }

  Future<String> readProfile() async {
    try {
      final file = await _profileFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "N/A";
    }
  }

  Future<bool> checkIfProfileFileExists() async {
    final file = await _profileFile;

    return await file.exists();
  }

  Future<void> deleteFile() async {
    final file = await _profileFile;
    bool fileExists = await checkIfProfileFileExists();

    if (fileExists) {
      try {
        await file.delete();
        print('File deleted');
      } catch (e) {
        print('Error deleting file: $e');
      }
    } else {
      print('File does not exist');
    }
  }

  // TRAINING PLAN FILE METHODS (JSON)
  Future<File> get _trainingPlanFile async {
    final path = await _localPath;
    return File('$path/training_plan.json');
  }

  Future<File> writeTrainingPlan(TrainingPlan plan) async {
    final path = await _localPath;
    final timestamp = plan.dateCreated.toIso8601String();
    final file = File('$path/training_plan_$timestamp.json');
    final jsonString = jsonEncode(plan.toJson());
    return file.writeAsString(jsonString);
  }

  Future<TrainingPlan?> readTrainingPlan() async {
    try {
      final file = await _trainingPlanFile;
      final contents = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(contents);
      return TrainingPlan.fromJson(json);
    } catch (e) {
      print("Error reading training plan: $e");
      return null;
    }
  }

  Future<bool> trainingPlanExists() async {
    final file = await _trainingPlanFile;
    return await file.exists();
  }

  Future<void> deleteTrainingPlanFile() async {
    final file = await _trainingPlanFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<TrainingPlan>> getAllTrainingPlans() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();

    List<TrainingPlan> plans = [];

    for (var file in files) {
      if (file is File &&
          file.path.endsWith('.json') &&
          file.path.contains('training_plan_')) {
        try {
          final jsonStr = await file.readAsString();
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
          final plan = TrainingPlan.fromJson(jsonMap);
          plans.add(plan);
        } catch (e) {
          print('Failed to read training plan file: ${file.path}, error: $e');
        }
      }
    }

    // Sort by dateCreated (newest first)
    plans.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

    return plans;
  }
}
