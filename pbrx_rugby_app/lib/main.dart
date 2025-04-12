import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/pages/main_app_page.dart';
import 'package:pbrx_rugby_app/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // required before using async in main

  final storage = StoreDataLocally();
  //this is here fore testing
  storage.deleteFile();
  late Profile profile;

  try {
    await dotenv.load(fileName: "assets/envFiles/testEnvironmentFile.env");
  } on FileNotFoundError catch (e) {
    print("testEnvironmentFile.env file not found: $e");
  } catch (e) {
    print("Unexpected error loading testEnvironmentFile.env: $e");
  }

  bool fileExists = await storage.checkIfProfileFileExists();

  if (fileExists) {
    String profileString = await storage.readProfile();
    try {
      profile = Profile.stringToProfile(profileString);
    } catch (e) {
      print('Failed to parse profile: $e');
      // You could assign a default profile instead:
      profile = Profile(name: "", position: Position.back, skills: []);
      fileExists = false;
    }
  } else {
    profile = Profile(name: "", position: null, skills: []);
  }

  runApp(MyApp(
    showOnboarding: !fileExists,
    profile: profile,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showOnboarding, required this.profile});
  final bool showOnboarding;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBRX Rugby App',
      theme: ThemeData(
        useMaterial3: true, //this is changing the theme e.g. button looks like
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(
                255, 198, 244, 253)), //this is colour theme
      ),
      home: showOnboarding
          ? OnboardingPage()
          : MainAppPage(
              profile: profile!,
            ),
    );
  }
}
