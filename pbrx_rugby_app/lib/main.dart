import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/pages/main_app_page.dart';
import 'package:pbrx_rugby_app/pages/onboarding_page.dart';

/// The entry pointof the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StoreDataLocally();

  // For testing: DELETE THIS BEFORE TESTING IS DOEN
  storage.deleteFile();

  late Profile profile;

  // Load environment variables from the .env file
  try {
    await dotenv.load(fileName: "assets/envFiles/testEnvironmentFile.env");
  } on FileNotFoundError catch (e) {
    print("testEnvironmentFile.env file not found: $e");
  } catch (e) {
    print("Unexpected error loading testEnvironmentFile.env: $e");
  }

  // check if the user profile file already exists
  bool fileExists = await storage.checkIfProfileFileExists();

  if (fileExists) {
    // If it exists attempt to read profile
    String profileString = await storage.readProfile();
    try {
      profile = Profile.stringToProfile(profileString);
    } catch (e) {
      print('Failed to parse profile: $e');
      // fallback to a default profile if parsing fails
      profile = Profile(name: "", position: null, skills: []);
      fileExists = false;
    }
  } else {
    // If no file exists, initialize an empty profile with no position
    profile = Profile(name: "", position: null, skills: []);
  }

  // Launch the app with onboarding or main page based on profile availability
  runApp(MyApp(
    showOnboarding: !fileExists,
    profile: profile,
  ));
}

/// Root widget for the PBRX Rugby App
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showOnboarding, required this.profile});

  final bool showOnboarding; // determines if onboarding screen should be shown
  final Profile? profile; // users profile

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBRX Rugby App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 198, 244, 253),
        ),
      ),
      // Show onboarding page if profile is not set else go to main app
      home: showOnboarding
          ? OnboardingPage()
          : MainAppPage(
              profile: profile!,
            ),
    );
  }
}
