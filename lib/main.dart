import "package:flutter/material.dart";
import 'package:moviefinder/pages/home.dart';
import 'package:moviefinder/pages/main_app.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainApp()
        // home: Scaffold(
        //   backgroundColor: Color(0xFF292929),
        //   body: SingleChildScrollView(
        //     child: MainApp(),
        //   ),
        // ),
        );
  }
}
