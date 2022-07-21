import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import 'package:moviefinder/pages/home.dart';
import 'package:moviefinder/pages/main_app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainApp();
        } else {
          return const Scaffold(
            backgroundColor: Color(0xFF292929),
            body: SingleChildScrollView(
              child: Home(),
            ),
          );
        }
      },
    ));
  }
}
