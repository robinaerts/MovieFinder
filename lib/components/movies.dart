import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../secrets.dart';
import './rate_movie.dart';
import "package:flutter/material.dart";

class Movies extends StatefulWidget {
  const Movies({Key? key}) : super(key: key);

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  int movieNumber = 0;
  int page = 1;
  var movies;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-5041240051853060/1944718358",
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {});
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }),
        request: const AdRequest());
    _bannerAd!.load();
  }

  void nextMovie() {
    setState(() {
      movieNumber++;
    });
  }

  Future<void> ratedMovie({required bool liked}) async {
    final User user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.doc("users/${user.uid}").update({
      "rated": FieldValue.arrayUnion([
        {
          'movieId': movies[movieNumber]["id"],
          'liked': liked,
          'movieTitle': movies[movieNumber]["original_title"],
          "moviePoster": movies[movieNumber]["poster_path"],
        }
      ])
    });

    setState(() {
      nextMovie();
    });
  }

  Future<List<String>> getMovieProviders(String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    bool availableOnStreaming = prefs.getBool("onlyStreaming") ?? false;

    Uri providerUrl = Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$mdbKey");
    var providerRes = await http.get(providerUrl);
    var providerData = jsonDecode(providerRes.body);
    List<String> providers;
    if (providerData["results"]["BE"] != null &&
        providerData["results"]["BE"]["flatrate"] != null) {
      providers = List<String>.from(providerData["results"]["BE"]["flatrate"]
          .map((provider) => provider["provider_name"])
          .toList());
    } else {
      providers = [];
    }
    if (availableOnStreaming &&
        !providers.contains("Netflix") &&
        !providers.contains("Amazon Prime") &&
        !providers.contains("Disney Plus") &&
        !providers.contains("Amazon Video")) {
      providers = [];
    }
    return providers;
  }

  Future<List<dynamic>> getPopularMovies() async {
    var userid = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance.doc("users/$userid").get();
    var rated = snapshot.data()!["rated"];
    Uri url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$mdbKey&page=$page');
    var response = await http.get(url);
    dynamic temp = jsonDecode(response.body)["results"];
    var exclusiveMovies = [];

    for (var movie in temp) {
      if ((rated.singleWhere((rate) => rate["movieId"] == movie["id"],
              orElse: () => null)) !=
          null) {
      } else {
        movie["providers"] = await getMovieProviders(movie["id"].toString());
        if (movie["providers"].isNotEmpty) {
          exclusiveMovies.add(movie);
        }
        // exclusiveMovies.add(movie);
      }
    }
    setState(() => {movies = exclusiveMovies});
    page++;
    return exclusiveMovies;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          (movies == null || movieNumber >= movies.length)
              ? FutureBuilder(
                  future: getPopularMovies(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const Text('An error occured');
                      case ConnectionState.waiting:
                        return const Text('Loading movies...');
                      default:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return RateMovie(movie: snapshot.data);
                        }
                    }
                  },
                )
              : RateMovie(movie: movies[movieNumber]),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () => ratedMovie(liked: false),
                    icon: const Icon(
                      Icons.thumb_down,
                      color: Colors.blueAccent,
                    )),
                IconButton(
                    onPressed: () => ratedMovie(liked: true),
                    icon: const Icon(Icons.favorite, color: Colors.blueAccent))
              ],
            ),
          ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
