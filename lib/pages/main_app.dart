import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviefinder/components/movies.dart';
import 'package:moviefinder/components/overview.dart';
import 'package:moviefinder/components/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';

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
  bool _dependenciesInitialized = false;

  @override
  void initState() {
    super.initState();
    // Preload images moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      // Preload images
      precacheImage(const AssetImage("assets/images/icon.png"), context);
      _dependenciesInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? Scaffold(
            appBar: AppBar(
              leading: Image.asset(
                "assets/images/icon.png",
                height: 40,
                width: 40,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                isAntiAlias: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: frame != null ? child : const SizedBox(),
                  );
                },
              ),
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text(
                "MovieFinder",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                SvgPicture.asset(
                  "assets/images/tmdb.svg",
                  height: 15,
                  cacheColorFilter: true,
                  placeholderBuilder: (context) =>
                      const SizedBox(height: 15, width: 15),
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: ((selectedPage == 0)
                ? const Overview()
                : (selectedPage == 1)
                ? const Movies()
                : Profile()),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie),
                  label: "Movies",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.face),
                  label: "Your Profile",
                ),
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
            child: const Text("Sign in"),
          );
  }
}
