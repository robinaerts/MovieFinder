import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 90.0),
      child: (Column(
        children: [
          Text(
            "MOVIE\nFINDER",
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                letterSpacing: 4,
                fontSize: 50),
            textAlign: TextAlign.center,
          ),
          Container(
            margin: const EdgeInsets.only(top: 30.0),
            child: Text(
              "Find the movie that suits everyones needs",
              style: GoogleFonts.roboto(
                  color: const Color(0xffA6A6A6),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  fontSize: 27),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30.0, bottom: 80),
            child: ElevatedButton(
                onPressed: () {}, child: const Text("GET STARTED")),
          ),
          Image.asset(
            "assets/images/movie.png",
          ),
        ],
      )),
    );
  }
}
