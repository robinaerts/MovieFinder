import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 90.0),
      child: Center(
        child: (Column(
          children: [
            Image.asset(
              "assets/images/icon.png",
              height: 150,
            ),
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
              margin: const EdgeInsets.only(top: 50.0),
              child: Text(
                "Find the movie that suits everyones needs",
                style: GoogleFonts.roboto(
                    color: const Color.fromARGB(255, 236, 236, 236),
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    fontSize: 27),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30.0, bottom: 40.0),
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xfff9f38f),
                  )),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/signin");
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("GET STARTED",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff042940))),
                  )),
            ),
            kIsWeb
                ? InkWell(
                    child: const Text(
                      'Download the free Android app!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    onTap: () => launch(
                        'https://play.google.com/store/apps/details?id=com.robyte.moviefinder'),
                  )
                : Container(),
            const SizedBox(height: 50),
            Image.asset(
              "assets/images/movie.png",
            ),
          ],
        )),
      ),
    );
  }
}
