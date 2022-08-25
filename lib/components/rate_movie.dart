import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "../tools/getProviderImage.dart";

class RateMovie extends StatelessWidget {
  final dynamic movie;
  const RateMovie({Key? key, required this.movie}) : super(key: key);

  Future<void> _launchUrl() async {
    final Uri trailer = Uri.parse(
        "https://www.youtube.com/results?search_query=${movie['original_title']} trailer");
    if (!await launchUrl(trailer)) return;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 600,
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 20),
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.network(
                        'https://image.tmdb.org/t/p/w300/${movie["backdrop_path"]}'),
                    Text(
                      movie["original_title"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      movie["overview"],
                      textAlign: TextAlign.center,
                    ),
                    Column(
                      children: [
                        const Text("RATING",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(movie["vote_average"].toString()),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...movie["providers"]
                                .map((provider) => getProviderImage(provider))
                                .toList()
                          ]),
                    ),
                    OutlinedButton(
                        onPressed: _launchUrl, child: const Text("Trailer"))
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
