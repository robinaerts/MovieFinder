import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moviefinder/models/movie_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MovieInfo extends StatelessWidget {
  final movieId;
  const MovieInfo({Key? key, required this.movieId}) : super(key: key);

  Future<MovieDetails> _getAllData() async {
    // Get some sharedpreferences to map data on correct region
    final prefs = await SharedPreferences.getInstance();
    String language = prefs.getString("language") ?? "en";
    String region = prefs.getString("region") ?? "BE";

    // Get basic info
    Uri url = Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$mdbKey&language=$language');
    var response = await http.get(url);
    var basicData = jsonDecode(response.body);
    String title = basicData["original_title"];
    String description = basicData["overview"];
    String cover = basicData["backdrop_path"];
    List<String> genres = List<String>.from(
        basicData["genres"].map((genre) => genre["name"]).toList());

    // Get providers
    Uri providerUrl = Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$mdbKey");
    var providerRes = await http.get(providerUrl);
    var providerData = jsonDecode(providerRes.body);
    List<String> providers;
    if (providerData["results"][region] != null &&
        providerData["results"][region]["flatrate"] != null) {
      providers = List<String>.from(providerData["results"][region]["flatrate"]
          .map((provider) => provider["provider_name"])
          .toList());
    } else {
      providers = [];
    }

    return MovieDetails(
        title: title,
        description: description,
        providers: providers,
        cover: cover,
        genres: genres);
  }

  Widget getProviderImage(String providerName) {
    switch (providerName) {
      case "Netflix":
        return Image.network(
          "https://s3.amazonaws.com/ionic-marketplace/ionic-4-netflix-style-video-streaming/icon.png",
        );
      case "Yelo Play":
        return Image.network(
            "https://cdn.fing.io/images/isp/BE/logo/telenet_logo.png");
      case "Disney Plus":
        return Image.network("https://pic.clubic.com/v1/images/1787948/raw");
      default:
        return Text(providerName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: FutureBuilder(
        future: _getAllData(),
        builder: (BuildContext context, AsyncSnapshot<MovieDetails> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('An error occured');
            case ConnectionState.waiting:
              return const Text('Loading movies...');
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                MovieDetails movie = snapshot.data!;
                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                            'https://image.tmdb.org/t/p/w500/${movie.cover}'),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 370,
                          child: Text(
                            movie.description,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...movie.providers
                                    .map((provider) =>
                                        getProviderImage(provider))
                                    .toList()
                              ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: movie.genres
                                .map((genre) => Text(
                                      genre,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600),
                                    ))
                                .toList())
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
