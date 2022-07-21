import "package:flutter/material.dart";
import '../models/simple_movie_data.dart';

class Overview extends StatelessWidget {
  Overview({Key? key}) : super(key: key);

  final popularMovies = [
    SimpleMovieData(
        title: "Harry Potter",
        genre: "Fantasy",
        img:
            "https://d1w7fb2mkkr3kw.cloudfront.net/assets/images/book/lrg/9781/7805/9781780548371.jpg",
        id: "m1"),
    SimpleMovieData(
        title: "Die Hard",
        genre: "Action",
        img:
            "https://sacramento.downtowngrid.com/wp-content/uploads/2019/10/Die-Square-700x700.jpg",
        id: "m2"),
    SimpleMovieData(
        title: "Snowwhite",
        genre: "Fairy Tale",
        img:
            "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/0d7f10a8-159b-4916-9ab4-fae3a5fefb62/de3pfgg-9f9b72c6-87f2-4dba-b74c-b3effa0feefd.jpg/v1/fill/w_1280,h_1280,q_75,strp/snow_white__disney__square_by_alittlecuriousfan99_de3pfgg-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTI4MCIsInBhdGgiOiJcL2ZcLzBkN2YxMGE4LTE1OWItNDkxNi05YWI0LWZhZTNhNWZlZmI2MlwvZGUzcGZnZy05ZjliNzJjNi04N2YyLTRkYmEtYjc0Yy1iM2VmZmEwZmVlZmQuanBnIiwid2lkdGgiOiI8PTEyODAifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.hMjcvNO5mHeE8pWUggYRepBErZ9C1WeTcHYbRCJVnss",
        id: "m3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.only(left: 20, bottom: 20, top: 20),
          child: const Text(
            "Most Popular",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          height: 500,
          child: ListView(
              children: popularMovies
                  .map(
                    (movie) => ListTile(
                      leading: Image.network(movie.img, fit: BoxFit.contain),
                      title: Text(movie.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(movie.genre),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.launch),
                      ),
                    ),
                  )
                  .toList()),
        )
      ]),
    );
  }
}
