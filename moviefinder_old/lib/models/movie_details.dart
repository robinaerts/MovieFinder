class MovieDetails {
  final String title;
  final String description;
  final List<String> providers;
  final String cover;
  final List<String> genres;

  MovieDetails(
      {required this.title,
      required this.description,
      required this.providers,
      required this.cover,
      required this.genres});
}
