import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviefinder/components/movies.dart';
import 'package:moviefinder/components/overview.dart';
import 'package:moviefinder/components/profile.dart';
import 'package:moviefinder/pages/settings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  int selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? Scaffold(
            appBar: AppBar(
                leading: Image.asset("assets/images/icon.png"),
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text("Movie Finder"),
                actions: [
                  SvgPicture.asset("assets/images/tmdb.svg", height: 15),
                  const SizedBox(width: 30),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => const Settings())));
                      },
                      icon: const Icon(Icons.settings))
                ]),
            body: ((selectedPage == 0)
                ? const Overview()
                : (selectedPage == 1)
                    ? const Movies()
                    : Profile()),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.movie), label: "Movies"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.face), label: "Your Profile")
              ],
              currentIndex: selectedPage,
              onTap: (value) {
                setState(() {
                  selectedPage = value;
                });
              },
            ),
          )
        : ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed("/signin"),
            child: const Text("Sign in"));
  }
}
