import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import 'package:moviefinder/pages/home.dart';
import 'package:moviefinder/pages/login.dart';
import 'package:moviefinder/pages/main_app.dart';
import 'package:moviefinder/pages/signup.dart';
import "firebase_options.dart";
import 'package:url_strategy/url_strategy.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setPathUrlStrategy();

  // Configure image cache
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB

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
      title: "MovieFinder | Find the perfect movie",
      initialRoute: "/",
      routes: {
        "/signin": (context) => const Login(),
        "/signup": (context) => const Signup(),
        "/app": (context) => const MainApp(),
      },
      theme: ThemeData(
        primaryColor: const Color(0xff042940),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xff042940),
          secondary: const Color(0xfff9f38f),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainApp();
          } else {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: const SingleChildScrollView(child: Home()),
            );
          }
        },
      ),
    );
  }
}
