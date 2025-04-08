import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/pages/main_app_page.dart';
import 'package:pbrx_rugby_app/pages/onboarding_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // required before using async in main

  final storage = StoreDataLocally();
  bool fileExists = await storage.checkIfFileExists();

  runApp(MyApp(showOnboarding: !fileExists));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showOnboarding});
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PBRX Rugby App',
        theme: ThemeData(
          useMaterial3: true, //this is changing the theme e.g. button looks like
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 198, 244, 253)), //this is colour theme
        ),
        home: showOnboarding ? OnboardingPage() : MainAppPage(),
    );
  }
}



// //class that is generating the random words using the a package installed at the top
// //this is where functionality goes, varibales and methods/functions will go here.
// class MyAppState extends ChangeNotifier {
//   var current = WordPair.random(); //creates variable that can be used later 

//   //method that updated current to new random pair
//   void getNext() {
//     current = WordPair.random();
//     notifyListeners();
//   }

//   var favorites = <WordPair>[];

//   void toggleFavorite() {
//     if (favorites.contains(current)) {
//       favorites.remove(current);
//     } else {
//       favorites.add(current);
//     }
//     notifyListeners();
//   }
// }


