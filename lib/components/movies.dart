import 'dart:convert';
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
          ElevatedButton(onPressed: nextMovie, child: const Text("Next"))
        ],
      ),
    );
  }
}
