import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:moviefinder/pages/movie_info.dart';
import '../models/simple_movie_data.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  var popularMovies = [];

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
                  img: 'http://image.tmdb.org/t/p/w92${rate["moviePoster"]}',
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
                  img: 'http://image.tmdb.org/t/p/w92${rate["moviePoster"]}',
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
    });
  }

  @override
  void initState() {
    getBestChoises();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          margin: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                child: popularMovies.length > 0
                    ? ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) => ListTile(
                          leading: Image.network(popularMovies[index].img,
                              fit: BoxFit.contain),
                          title: Text(popularMovies[index].title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      color: Colors.white70),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.grey[300]),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: SkeletonAnimation(
                                                child: Container(
                                                  width: 60,
                                                  height: 13,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Colors.grey[300]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )));
                        }))
          ])),
    );
  }
}
