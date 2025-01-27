import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'PBRX Rugby App',
        theme: ThemeData(
          useMaterial3: true, //this is changing the theme e.g. button looks like
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 170, 255)), //this is colour theme
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//class that is generating the random words using the a package installed at the top
//this is where functionality goes, varibales and methods/functions will go here.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); //creates variable that can be used later 

  //method that updated current to new random pair
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}


//this is where the app is kinda building what goes on to the UI in widgets
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text('A random idea, by Megan Miles, again:'), //simple text
          Text(appState.current.asLowerCase), //this is the random word pair, current is taken from the class above 

          ElevatedButton(
            onPressed: () {
              //print('button pressed!'); //prints on console
              //when button is pressed the appState runs the getNext method
              appState.getNext();
            },
            child: Text('Next'), //text of button, this could be ANY widget in Flutter
          ),
        ],
      ),
    );
  }
}