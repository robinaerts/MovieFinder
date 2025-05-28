import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "../tools/getProviderImage.dart";
// import 'package:swipe_cards/swipe_cards.dart'; // Not used directly here anymore

class RateMovie extends StatelessWidget {
  final dynamic movie;
  const RateMovie({Key? key, required this.movie}) : super(key: key);

  Future<void> _launchUrl() async {
    // Safely access title, providing a default if null or not a string
    final String movieTitle = movie?['original_title'] is String
        ? movie!['original_title']
        : 'movie trailer';
    final Uri trailer = Uri.parse(
      "https://www.youtube.com/results?search_query=${Uri.encodeComponent(movieTitle)} trailer",
    );
    try {
      if (!await launchUrl(trailer)) {
        print('Could not launch $trailer');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle cases where movie or its properties might be null to prevent runtime errors
    final String backdropPath = movie?["backdrop_path"] is String
        ? movie!["backdrop_path"]
        : "";
    final String originalTitle = movie?["original_title"] is String
        ? movie!["original_title"]
        : "No title available";
    final String overview = movie?["overview"] is String
        ? movie!["overview"]
        : "No overview available.";
    final String voteAverage = movie?["vote_average"]?.toString() ?? "N/A";
    final List<dynamic> providers = movie?["providers"] is List
        ? movie!["providers"]
        : [];

    return GestureDetector(
      // The GestureDetector is for the whole card if you want taps on it.
      // If it was just for the trailer button, it's fine on the button itself.
      // For now, let it be on the card, but ensure it doesn't interfere with scrolling.
      // Consider moving it if only the trailer button should be tappable for trailer.
      // onTap: _launchUrl, // Example: if the whole card should launch trailer, which is unusual.
      child: Container(
        height: 600, // This height is for the card area in SwipeCards
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(
          top: 20,
          bottom: 20,
        ), // Added bottom margin for breathing room
        child: FractionallySizedBox(
          widthFactor: 0.85, // Slightly increased width
          child: Card(
            elevation: 5,
            clipBehavior:
                Clip.antiAlias, // Ensures content respects card border radius
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // More rounded corners
            ),
            child: Padding(
              // Changed Container to Padding for simplicity
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceAround, // Removed for scroll view
                  children: [
                    if (backdropPath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500/$backdropPath', // Larger image quality
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium, // Better quality
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: frame != null
                                      ? child
                                      : const SizedBox(
                                          height: 180,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ), // Placeholder height
                                );
                              },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180, // Placeholder height
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else // Fallback if no backdrop_path
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.movie_creation_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      originalTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Slightly larger title
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overview,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        const Text(
                          "RATING",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          voteAverage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (providers.isNotEmpty)
                      SizedBox(
                        height:
                            35, // Slightly increased height for provider icons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: providers
                              .map(
                                (provider) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3.0,
                                  ),
                                  child: getProviderImage(provider),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 35,
                        child: Center(
                          child: Text(
                            "No providers listed",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text("Trailer"),
                      onPressed: _launchUrl,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ), // Some bottom padding inside scroll view
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
