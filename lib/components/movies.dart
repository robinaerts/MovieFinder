import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
  var movies;

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

  Future<List<dynamic>> getPopularMovies({int page = 1}) async {
    Uri url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$mdbKey&page=$page');
    var response = await http.get(url);
    dynamic temp = jsonDecode(response.body)["results"];
    setState(() => {movies = temp});
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          (movies == null)
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
          )
        ],
      ),
    );
  }
}
