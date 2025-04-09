import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:pbrx_rugby_app/models/profile.dart';

class StoreDataLocally {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/profile.txt');
}

Future<File> writeProfile(Profile profile) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString(profile.toString());
}

Future<String> readProfile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return "N/A";
  }
}
Future<bool> checkIfFileExists() async {
  final file = await _localFile;

  return await file.exists();
}

Future<void> deleteFile() async {
  final file = await _localFile;
  bool fileExists = await checkIfFileExists();


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
}
