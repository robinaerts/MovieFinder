import 'package:flutter/material.dart';
import 'package:moviefinder/components/movies.dart';
import 'package:moviefinder/components/overview.dart';
import 'package:moviefinder/components/profile.dart';
import 'package:moviefinder/pages/settings.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie Finder"), actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => const Settings())));
            },
            icon: const Icon(Icons.settings))
      ]),
      body: ((selectedPage == 0)
          ? const Overview()
          : (selectedPage == 1)
              ? const Movies()
              : const Profile()),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Your Profile")
        ],
        currentIndex: selectedPage,
        onTap: (value) {
          setState(() {
            selectedPage = value;
          });
        },
      ),
    );
  }
}
