class SimpleMovieData {
  final String title;
  final String genre;
  final String id;
  final String img;
  int likedCount;
  int dislikedCount;

  SimpleMovieData(
      {required this.title,
      required this.genre,
      required this.id,
      required this.img,
      required this.likedCount,
      required this.dislikedCount});
}
