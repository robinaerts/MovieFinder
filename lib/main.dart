import "package:flutter/material.dart";
import 'package:moviefinder/pages/home.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          new Scaffold(backgroundColor: Color(0xFF292929), body: const Home()),
    );
  }
}
