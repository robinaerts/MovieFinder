import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:moviefinder/pages/movie_info.dart';
import 'package:moviefinder/secrets.dart';
import '../models/simple_movie_data.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:http/http.dart' as http;
import 'package:moviefinder/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  var popularMovies = [];
  var recommended = [];

  BannerAd? _bannerAd;

  void getBestChoises() {
    FirebaseFirestore.instance
        .collection("groups")
        .where("members", arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      dynamic members = snapshot.docs[0].data()["members"];
      var users = [];
      for (var member in members) {
        var user = await FirebaseFirestore.instance.doc("users/$member").get();
        users.add(user.data());
      }
      var tempPopular = [...popularMovies];
      for (var user in users) {
        for (var rate in user["rated"]) {
          if (rate["liked"]) {
            if ((tempPopular.singleWhere(
                    (element) => element.id == rate["movieId"].toString(),
                    orElse: () => null)) !=
                null) {
              tempPopular
                  .singleWhere(
                      (element) => element.id == rate["movieId"].toString())
                  .likedCount++;
            } else {
              tempPopular.add(SimpleMovieData(
                  title: rate["movieTitle"],
                  genre: "WIP",
                  id: rate["movieId"].toString(),
                  img: 'https://image.tmdb.org/t/p/w92${rate["moviePoster"]}',
                  likedCount: 1,
                  dislikedCount: 0));
            }
          } else {
            if ((tempPopular.singleWhere(
                    (element) => element.id == rate["movieId"].toString(),
                    orElse: () => null)) !=
                null) {
              tempPopular
                  .singleWhere(
                      (element) => element.id == rate["movieId"].toString())
                  .dislikedCount++;
            } else {
              tempPopular.add(SimpleMovieData(
                  title: rate["movieTitle"],
                  genre: "WIP",
                  id: rate["movieId"].toString(),
                  img: 'https://image.tmdb.org/t/p/w92${rate["moviePoster"]}',
                  likedCount: 0,
                  dislikedCount: 1));
            }
          }
        }
      }
      tempPopular.sort(((a, b) {
        double bPercentage = b.likedCount / members.length;
        double aPercentage = a.likedCount / members.length;
        return bPercentage.compareTo(aPercentage);
      }));
      setState(() {
        popularMovies = [...tempPopular];
      });
      getRecommended(popularMovies[0].id);
    });
  }

  void getRecommended(String id) async {
    Uri url = Uri.parse(
        "https://api.themoviedb.org/3/movie/$id/recommendations?api_key=$mdbKey");
    var response = await http.get(url);
    dynamic temp = jsonDecode(response.body)["results"].toList();
    List movies = [];
    for (int i = 0; i < 10; i++) {
      movies.add({
        "title": temp[i]["title"],
        "img": temp[i]["poster_path"],
        "id": temp[i]["id"].toString(),
        "description": temp[i]["overview"],
      });
    }
    setState(() {
      recommended = movies;
    });
  }

  @override
  void initState() {
    getBestChoises();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              PopularMovies(popularMovies: popularMovies),
              Recommended(recommended: recommended),
              AdWidget(ad: _bannerAd!),
            ],
          )),
    );
  }
}

class Recommended extends StatelessWidget {
  const Recommended({
    Key? key,
    required this.recommended,
  }) : super(key: key);

  final List recommended;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 20, bottom: 20, top: 70),
        child: const Text(
          "Recommended for you",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      recommended.isNotEmpty
          ? SizedBox(
              height: 300,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MovieInfo(
                              movieId: recommended[index]["id"],
                            ),
                          ),
                        ),
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Column(children: [
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "https://image.tmdb.org/t/p/w92${recommended[index]["img"]}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Text(
                                  recommended[index]["title"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ])),
                      )),
            )
          : const Text("No recommendations")
    ]);
  }
}

class PopularMovies extends StatelessWidget {
  const PopularMovies({
    Key? key,
    required this.popularMovies,
  }) : super(key: key);

  final List popularMovies;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
        child: const Text(
          "Most Popular",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      SizedBox(
          height: 400,
          child: popularMovies.isNotEmpty
              ? ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) => ListTile(
                    leading: Image.network(popularMovies[index].img,
                        fit: BoxFit.contain),
                    title: Text(popularMovies[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Liked: ${popularMovies[index].likedCount} / ${popularMovies[index].dislikedCount + popularMovies[index].likedCount}"),
                    trailing: IconButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            MovieInfo(movieId: popularMovies[index].id),
                      )),
                      icon: const Icon(Icons.launch),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                color: Colors.white70),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SkeletonAnimation(
                                  child: Container(
                                    width: 70.0,
                                    height: 70.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, bottom: 5.0),
                                      child: SkeletonAnimation(
                                        child: Container(
                                          height: 15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[300]),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: SkeletonAnimation(
                                          child: Container(
                                            width: 60,
                                            height: 13,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color: Colors.grey[300]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )));
                  })),
    ]);
  }
}
