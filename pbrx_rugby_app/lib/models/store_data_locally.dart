import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';

//Handles local storage of user data including profile and training plans.
//Uses file system operations to persist data across app launches 
class StoreDataLocally {
  /// Returns the path to the apps local documents directory 
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Gets the file reference for the profile file (profile.txt)
  Future<File> get _profileFile async {
    final path = await _localPath;
    return File('$path/profile.txt');
  }

  // Saves the users profile as a string to local storage 
  Future<File> writeProfile(Profile profile) async {
    final file = await _profileFile;
    return file.writeAsString(profile.toString()); 
  }

  // Reads the saved profile string from local storage. 
  Future<String> readProfile() async {
    try {
      final file = await _profileFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // Return default string, if read fails 
      return "N/A";
    }
  }

  //checks whether the profile file exists in local storage
  Future<bool> checkIfProfileFileExists() async {
    final file = await _profileFile;
    return await file.exists();
  }

  /// Deletes the profile file from local storage if it exists
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

  // -------------------------------
  // TRAINING PLAN FILE METHODS (JSON)
  // -------------------------------

  /// Gets the default training plan file (used in readTrainingPlan, trainingPlanExists)
  Future<File> get _trainingPlanFile async {
    final path = await _localPath;
    return File('$path/training_plan.json');
  }

  /// Saves a training plan as a JSON file named with its creation timestamp 
  Future<File> writeTrainingPlan(TrainingPlan plan) async {
    final path = await _localPath;
    final timestamp = plan.dateCreated.toIso8601String();
    final file = File('$path/training_plan_$timestamp.json');
    final jsonString = jsonEncode(plan.toJson());
    return file.writeAsString(jsonString);
  }

  /// Reads the default training plan JSON file and returns a training Plan object 
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

  /// Checks whether the default training plan file exists
  Future<bool> trainingPlanExists() async {
    final file = await _trainingPlanFile;
    return await file.exists();
  }

  //Deletes the default training plan file (training_plan.json) if it exists
  Future<void> deleteTrainingPlanFile() async {
    final file = await _trainingPlanFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  ///Re-ads all saved training plans from local storage (training_plan_*.json files),
  // sorts them by creation date 
  Future<List<TrainingPlan>> getAllTrainingPlans() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync(); // List all files in the directory

    List<TrainingPlan> plans = [];

    for (var file in files) {
      // Match only training plan files
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

    // Sort training plans by dateCreated in descending order where most recent is first
    plans.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

    return plans;
  }
}
