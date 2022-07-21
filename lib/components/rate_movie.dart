import 'package:flutter/material.dart';

class RateMovie extends StatefulWidget {
  const RateMovie({Key? key}) : super(key: key);

  @override
  State<RateMovie> createState() => _RateMovieState();
}

class _RateMovieState extends State<RateMovie> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 20),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Image"),
                  const Text("TITLE"),
                  const Text(
                    "Movie Description some dummy text to tell the main lines of the movie",
                    textAlign: TextAlign.center,
                  ),
                  Column(
                    children: const [
                      Text("CAST: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Actor 1, Actor 2, Actor 3"),
                    ],
                  ),
                  Column(
                    children: const [
                      Text("RATING",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("7.2"),
                    ],
                  ),
                  OutlinedButton(onPressed: () {}, child: const Text("Trailer"))
                ]),
          ),
        ),
      ),
    );
  }
}
