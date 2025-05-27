import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../secrets.dart';
import './rate_movie.dart';
import "package:flutter/material.dart";

class Movies extends StatefulWidget {
  const Movies({Key? key}) : super(key: key);

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  int movieNumber = 0;
  int page = 1;
  List<dynamic> movies =
      []; // Movies currently being displayed or ready for immediate display
  List<dynamic> movieQueue = []; // Background buffer
  bool isLoading = false; // True when actively fetching pages or processing
  bool noMoreMoviesAvailable =
      false; // True if determined that no more movies can be loaded
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final _adContainerKey = GlobalKey();
  final Map<String, List<String>> _providerCache = {};
  List<dynamic> ratedMovies = [];
  bool availableOnStreaming = false;
  final int minQueueSize = 10; // Minimum desired movies in the queue
  final int maxPagesToFetchInCycle =
      3; // Max pages to fetch in one go for _loadMoviesUntilQueueFilled
  final int maxTotalPages = 50; // Absolute max pages to ever fetch

  @override
  void initState() {
    super.initState();
    _initializeDataAndLoadMovies();
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-5041240051853060/1944718358",
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isAdLoaded = false;
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initializeDataAndLoadMovies() async {
    setState(() {
      isLoading = true;
      noMoreMoviesAvailable = false;
    });

    final prefs = await SharedPreferences.getInstance();
    availableOnStreaming = prefs.getBool("onlyStreaming") ?? false;

    var userid = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance.doc("users/$userid").get();
    ratedMovies = snapshot.data()?["rated"] ?? [];

    await _loadMoviesUntilQueueFilled(isInitialLoad: true);

    // After initial load, if movies list is still empty, it implies no movies were found.
    if (movies.isEmpty && movieQueue.isEmpty) {
      setState(() {
        noMoreMoviesAvailable = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<int> _fetchAndProcessPage() async {
    if (page > maxTotalPages) {
      return 0; // Stop fetching if max page limit reached
    }

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/movie/popular?api_key=$mdbKey&page=$page',
    );
    var response = await http.get(url);
    if (response.statusCode != 200) {
      print('Error fetching page $page: ${response.statusCode}');
      page++; // Increment page to avoid getting stuck on a failing page
      return 0;
    }
    dynamic moviesData = jsonDecode(response.body)["results"];
    if (moviesData == null || moviesData is! List || moviesData.isEmpty) {
      page++;
      return 0;
    }

    var unratedMovies = moviesData
        .where(
          (movie) =>
              !ratedMovies.any((rated) => rated["movieId"] == movie["id"]),
        )
        .toList();

    if (unratedMovies.isEmpty) {
      page++;
      return 0;
    }

    var futures = unratedMovies
        .map((movie) => _getMovieProvidersFromCache(movie["id"].toString()))
        .toList();

    var providersResults = await Future.wait(futures);
    int countAdded = 0;
    for (int i = 0; i < unratedMovies.length; i++) {
      var movie = unratedMovies[i];
      var providers = providersResults[i];

      if (providers.isNotEmpty) {
        movie["providers"] = providers;
        movieQueue.add(movie);
        countAdded++;
      }
    }
    page++;
    return countAdded;
  }

  Future<void> _loadMoviesUntilQueueFilled({bool isInitialLoad = false}) async {
    if (isLoading && !isInitialLoad)
      return; // Prevent re-entry for background fills if already loading pages
    if (noMoreMoviesAvailable && !isInitialLoad)
      return; // Don't try if we've flagged no more movies

    bool wasLoadingBefore = isLoading;
    if (!isInitialLoad)
      setState(() {
        isLoading = true;
      });

    int pagesFetchedThisCycle = 0;
    int moviesAddedToQueueThisCycle = 0;

    while (movieQueue.length < minQueueSize &&
        pagesFetchedThisCycle < maxPagesToFetchInCycle &&
        page <= maxTotalPages) {
      int addedCount = await _fetchAndProcessPage();
      moviesAddedToQueueThisCycle += addedCount;
      pagesFetchedThisCycle++;
      if (addedCount == 0 && pagesFetchedThisCycle > 1) {
        // If we fetch a couple of pages and get nothing, maybe slow down or stop this cycle
        // This can happen if filters are too strict or end of TMDB results for popular.
      }
    }

    // If this load attempt was critical (e.g., initial or movies list is empty)
    // and we got movies in the queue, move them to the main 'movies' list.
    if ((isInitialLoad || movies.isEmpty || movieNumber >= movies.length) &&
        movieQueue.isNotEmpty) {
      movies.addAll(movieQueue); // Append queue to movies
      movieQueue.clear();
      if (isInitialLoad || movieNumber >= movies.length) {
        // Reset movieNumber if we were out of bounds or initial
        movieNumber = 0;
      }
    }

    // Determine if no more movies are available
    if (pagesFetchedThisCycle >= maxPagesToFetchInCycle ||
        page > maxTotalPages) {
      // Tried our best for this cycle
      if (movieQueue.length < minQueueSize &&
          moviesAddedToQueueThisCycle == 0) {
        // Still not enough and added nothing new
        if (movies.isEmpty || movieNumber >= movies.length) {
          // And nothing to display
          setState(() {
            noMoreMoviesAvailable = true;
          });
        }
      }
    }
    if (!isInitialLoad || (isInitialLoad && !wasLoadingBefore)) {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  Future<List<String>> _getMovieProvidersFromCache(String movieId) async {
    if (_providerCache.containsKey(movieId)) {
      return _providerCache[movieId]!;
    }

    try {
      Uri providerUrl = Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$mdbKey",
      );
      var providerRes = await http.get(providerUrl);
      var providerData = jsonDecode(providerRes.body);
      List<String> providers = [];

      if (providerData["results"]?["BE"]?["flatrate"] != null) {
        providers = List<String>.from(
          providerData["results"]["BE"]["flatrate"]
              .map((provider) => provider["provider_name"])
              .toList(),
        );
      }

      if (availableOnStreaming) {
        providers = providers
            .where(
              (provider) =>
                  provider == "Netflix" ||
                  provider ==
                      "Amazon Prime Video" || // Adjusted "Amazon Prime" to "Amazon Prime Video"
                  provider == "Disney Plus" ||
                  provider == "Amazon Video",
            )
            .toList();
      }

      _providerCache[movieId] = providers;
      return providers;
    } catch (e) {
      print('Error fetching providers for movie $movieId: $e');
      _providerCache[movieId] = [];
      return [];
    }
  }

  void nextMovie() {
    if (movies.isEmpty && !isLoading && !noMoreMoviesAvailable) {
      // This case should ideally not be hit if loading logic is correct,
      // but as a safeguard, trigger a load.
      _loadMoviesUntilQueueFilled();
      return;
    }
    if (movieNumber < movies.length - 1) {
      setState(() {
        movieNumber++;
      });
    } else {
      // Reached end of current movies list
      setState(() {
        movieNumber++; // Tentatively move past the last item
      });
      if (movieQueue.isNotEmpty) {
        setState(() {
          movies.addAll(movieQueue); // Append remaining queue
          movieQueue.clear();
          // movieNumber remains valid as it's now an index in the expanded list,
          // or if it was movies.length, it's now the first new item.
          // No, if movieNumber was last valid index (length-1), after increment it's 'length'.
          // If we add N items, new length is old_length + N. movieNumber should point to old_length.
          // The current movieNumber after increment is already pointing to the first new item from queue.
        });
        // Proactively fill queue
        if (movieQueue.length < minQueueSize && !noMoreMoviesAvailable) {
          _loadMoviesUntilQueueFilled();
        }
      } else if (!isLoading && !noMoreMoviesAvailable) {
        // Movies exhausted, queue empty, not loading, and not flagged as no more. Try to load.
        _loadMoviesUntilQueueFilled();
      }
      // If after this, movieNumber is still >= movies.length, the build method will show loader or noMoreMovies.
    }

    // Proactive queue refill if getting low
    if (movies.length - movieNumber <= 3 &&
        movieQueue.length < minQueueSize &&
        !isLoading &&
        !noMoreMoviesAvailable) {
      _loadMoviesUntilQueueFilled();
    }
  }

  Future<void> ratedMovie({required bool liked}) async {
    if (movieNumber >= movies.length) return;

    final User user = FirebaseAuth.instance.currentUser!;
    final movieData = {
      'movieId': movies[movieNumber]["id"],
      'liked': liked,
      'movieTitle': movies[movieNumber]["original_title"],
      "moviePoster": movies[movieNumber]["poster_path"],
    };

    ratedMovies.add(movieData);

    await FirebaseFirestore.instance.doc("users/${user.uid}").update({
      "rated": FieldValue.arrayUnion([movieData]),
    });

    nextMovie();
  }

  Widget _buildAdContainer() {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      key: _adContainerKey,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    if (isLoading &&
        (movies.isEmpty || movieNumber >= movies.length) &&
        !noMoreMoviesAvailable) {
      // Actively loading and no movie to display currently (or at the end of a depleted list)
      mainContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading movies...'),
        ],
      );
    } else if (movieNumber < movies.length) {
      // We have a movie to display
      mainContent = RateMovie(movie: movies[movieNumber]);
    } else if (noMoreMoviesAvailable) {
      // No more movies can be loaded
      mainContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200),
          Icon(Icons.movie_filter_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 20),
          Text('No more movies found.', style: TextStyle(fontSize: 16)),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Try adjusting your filters or check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    } else {
      // Fallback: Should be loading if movies are exhausted and not 'noMoreMoviesAvailable'
      // This state implies movies are out, but isLoading is false, and not noMore.
      // This indicates a need to trigger a load.
      if (!isLoading) {
        // Ensure a load is triggered if somehow missed.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadMoviesUntilQueueFilled();
        });
      }
      mainContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Searching for more movies...'),
        ],
      );
    }

    bool buttonsDisabled =
        movieNumber >= movies.length ||
        (isLoading && (movies.isEmpty || movieNumber >= movies.length));
    if (noMoreMoviesAvailable && movieNumber >= movies.length) {
      buttonsDisabled = true;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height:
                650, // Assuming RateMovie and its container needs a fixed height
            alignment: Alignment.center,
            child: mainContent,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: buttonsDisabled
                      ? null
                      : () => ratedMovie(liked: false),
                  icon: const Icon(Icons.thumb_down, color: Colors.blueAccent),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: buttonsDisabled
                      ? null
                      : () => ratedMovie(liked: true),
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  iconSize: 30,
                ),
              ],
            ),
          ),
          _buildAdContainer(),
        ],
      ),
    );
  }
}
