import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        Text("MOVIE FINDER", style: GoogleFonts.roboto()),
        const Text("Find the movie that suits everyones needs"),
        TextButton(
            onPressed: () => print("Clicked!"),
            child: const Text("GET STARTED")),
        Image.asset("assets/images/movie.png"),
      ],
    ));
  }
}
