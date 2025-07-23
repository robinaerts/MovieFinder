import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../secrets.dart';
import './rate_movie.dart';
import "package:flutter/material.dart";
import 'dart:math' as math; // For Pi

class Movies extends StatefulWidget {
  const Movies({Key? key}) : super(key: key);

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  int page = 1;
  List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  List<dynamic> movieQueue = [];
  bool isLoading = false;
  bool noMoreMoviesAvailable = false;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final _adContainerKey = GlobalKey();
  final Map<String, List<String>> _providerCache = {};
  List<dynamic> ratedMovies = [];
  bool availableOnStreaming = false;
  final int minQueueSize = 10;
  final int maxPagesToFetchInCycle = 3;
  final int maxTotalPages = 50;
  int _currentCardIndex = 0;

  // New: endpoints to cycle through
  final List<Map<String, String>> _endpoints = [
    {"name": "Popular", "url": "https://api.themoviedb.org/3/movie/popular"},
    {
      "name": "Top Rated",
      "url": "https://api.themoviedb.org/3/movie/top_rated",
    },
    {
      "name": "Trending (Day)",
      "url": "https://api.themoviedb.org/3/trending/movie/day",
    },
    {
      "name": "Now Playing",
      "url": "https://api.themoviedb.org/3/movie/now_playing",
    },
    {"name": "Upcoming", "url": "https://api.themoviedb.org/3/movie/upcoming"},
  ];
  int _currentEndpointIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeDataAndLoadMovies();
    // _initBannerAd();
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
          print('Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _matchEngine?.dispose();
    super.dispose();
  }

  Future<void> _initializeDataAndLoadMovies() async {
    if (mounted)
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

    if (_swipeItems.isEmpty && movieQueue.isEmpty && mounted) {
      setState(() {
        noMoreMoviesAvailable = true;
      });
    }
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  Future<int> _fetchAndProcessPage() async {
    int endpointsTried = 0;
    while (endpointsTried < _endpoints.length) {
      if (page > maxTotalPages) {
        // Try next endpoint
        if (_currentEndpointIndex < _endpoints.length - 1) {
          _currentEndpointIndex++;
          page = 1;
        } else {
          // All endpoints exhausted
          return 0;
        }
        endpointsTried++;
        continue;
      }

      final endpoint = _endpoints[_currentEndpointIndex];
      Uri url = Uri.parse('${endpoint["url"]}?api_key=$mdbKey&page=$page');
      var response = await http.get(url);
      if (response.statusCode != 200) {
        page++;
        continue;
      }
      dynamic body = jsonDecode(response.body);
      dynamic moviesData;
      if (body["results"] != null) {
        moviesData = body["results"];
      } else if (body is List) {
        moviesData = body;
      } else {
        moviesData = [];
      }
      if (moviesData == null || moviesData is! List || moviesData.isEmpty) {
        page++;
        continue;
      }

      var unratedMovies = moviesData
          .where(
            (movie) =>
                !ratedMovies.any((rated) => rated["movieId"] == movie["id"]) &&
                !_swipeItems.any((item) => item.content["id"] == movie["id"]) &&
                !movieQueue.any(
                  (queuedMovie) => queuedMovie["id"] == movie["id"],
                ),
          )
          .toList();

      if (unratedMovies.isEmpty) {
        page++;
        continue;
      }

      var futures = unratedMovies
          .map((movie) => _getMovieProvidersFromCache(movie["id"].toString()))
          .toList();

      var providersResults = await Future.wait(futures);
      int countAdded = 0;
      for (int i = 0; i < unratedMovies.length; i++) {
        var movie = unratedMovies[i];
        var providers = providersResults[i];

        movie["providers"] = providers;
        movieQueue.add(movie);
        countAdded++;
      }
      page++;
      return countAdded;
    }
    // All endpoints exhausted
    return 0;
  }

  Future<void> _loadMoviesUntilQueueFilled({bool isInitialLoad = false}) async {
    if (isLoading && !isInitialLoad) return;
    if (noMoreMoviesAvailable && !isInitialLoad) return;

    bool wasLoadingBefore = isLoading;
    if (!isInitialLoad && mounted)
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
    }

    if (movieQueue.isNotEmpty) {
      List<SwipeItem> newSwipeItems = movieQueue
          .map((movie) => _createSwipeItem(movie))
          .toList();
      movieQueue.clear();

      if (mounted) {
        setState(() {
          _swipeItems.addAll(newSwipeItems);
          if (_swipeItems.isNotEmpty) {
            _matchEngine = MatchEngine(swipeItems: _swipeItems);
            if (isInitialLoad ||
                _currentCardIndex >= _swipeItems.length ||
                _matchEngine == null) {
              _currentCardIndex = 0;
            }
          } else {
            _matchEngine = null;
          }
        });
      }
    }

    if (pagesFetchedThisCycle >= maxPagesToFetchInCycle ||
        page > maxTotalPages) {
      if (_swipeItems.length < minQueueSize &&
          moviesAddedToQueueThisCycle == 0) {
        if (_swipeItems.isEmpty && mounted) {
          setState(() {
            noMoreMoviesAvailable = true;
          });
        }
      }
    }
    if ((!isInitialLoad || (isInitialLoad && !wasLoadingBefore)) && mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  SwipeItem _createSwipeItem(dynamic movieData) {
    return SwipeItem(
      content: movieData,
      likeAction: () {
        ratedMovie(movie: movieData, liked: true);
      },
      nopeAction: () {
        ratedMovie(movie: movieData, liked: false);
      },
      superlikeAction: () {
        ratedMovie(movie: movieData, liked: true);
      },
      // onSlideUpdate: (SlideRegion? region) {
      //   // This is a void callback. Its parameter SlideRegion? is nullable.
      //   // The linter error regarding Future<dynamic> was incorrect for this callback type.
      //   // The SlideRegion class itself should be found if the package is imported correctly.
      //   // If error persists, it might be a deeper linter/cache issue.
      //   // print("Region: $region"); // Keep commented for max stability
      // }
    );
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
          providerData["results"]!["BE"]!["flatrate"]!
              .map((provider) => provider["provider_name"])
              .toList(),
        );
      }

      _providerCache[movieId] = providers;
      return providers;
    } catch (e) {
      print('Error fetching providers for movie $movieId: $e');
      _providerCache[movieId] = [];
      return [];
    }
  }

  Future<void> ratedMovie({required dynamic movie, required bool liked}) async {
    final User user = FirebaseAuth.instance.currentUser!;

    ratedMovies.add({
      'movieId': movie["id"],
      'liked': liked,
      'movieTitle': movie["original_title"],
      "moviePoster": movie["poster_path"],
    });

    await FirebaseFirestore.instance.doc("users/${user.uid}").update({
      "rated": FieldValue.arrayUnion([
        {
          'movieId': movie["id"],
          'liked': liked,
          'movieTitle': movie["original_title"],
          "moviePoster": movie["poster_path"],
        },
      ]),
    });
  }

  Widget _buildAdContainer() {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      key: _adContainerKey,
      alignment: Alignment.center,
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

    Widget buildTag({
      required String text,
      required Color color,
      required double angle,
    }) {
      return Align(
        alignment: angle == 0
            ? Alignment.center
            : (angle < 0 ? Alignment.topLeft : Alignment.topRight),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Transform.rotate(
            angle: angle * (math.pi / 180), // Convert degrees to radians
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 32, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (isLoading && _swipeItems.isEmpty && !noMoreMoviesAvailable) {
      mainContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading movies...'),
        ],
      );
    } else if (_matchEngine != null &&
        _swipeItems.isNotEmpty &&
        _currentCardIndex < _swipeItems.length) {
      mainContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine!,
              itemBuilder: (BuildContext context, int index) {
                var movieData = _swipeItems[index].content;
                return RateMovie(movie: movieData);
              },
              onStackFinished: () {
                if (mounted) {
                  setState(() {
                    _matchEngine = null;
                    _currentCardIndex = 0;
                    if (_swipeItems.isEmpty) {
                      noMoreMoviesAvailable = true;
                    } else {
                      _swipeItems.clear();
                    }
                  });
                }
                if (!isLoading && !noMoreMoviesAvailable) {
                  _loadMoviesUntilQueueFilled();
                } else if (mounted && _swipeItems.isEmpty) {
                  setState(() {
                    noMoreMoviesAvailable = true;
                  });
                }
              },
              itemChanged: (SwipeItem item, int index) {
                if (mounted) {
                  setState(() {
                    _currentCardIndex = index;
                  });
                }
                if (_swipeItems.length - (index + 1) < 3 &&
                    !isLoading &&
                    !noMoreMoviesAvailable) {
                  _loadMoviesUntilQueueFilled();
                }
              },
              upSwipeAllowed: true,
              fillSpace: true,
              likeTag: buildTag(
                text: "LIKE",
                color: Colors.green.shade700,
                angle: -15,
              ),
              nopeTag: buildTag(
                text: "NOPE",
                color: Colors.red.shade700,
                angle: 15,
              ),
              superLikeTag: buildTag(
                text: "SUPER",
                color: Colors.blue.shade700,
                angle: 0,
              ),
            ),
          ),
          if (!isLoading &&
              !noMoreMoviesAvailable &&
              _swipeItems.isNotEmpty) // Show hint only when cards are active
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_left, color: Colors.red.shade300, size: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Swipe to rate",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  Icon(
                    Icons.swipe_right,
                    color: Colors.green.shade300,
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      );
    } else if (noMoreMoviesAvailable) {
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
      if (!isLoading && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              !_isAdLoaded &&
              _swipeItems.isEmpty &&
              !noMoreMoviesAvailable) {
            _loadMoviesUntilQueueFilled();
          }
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

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                top: 10,
              ), // Add some padding at the top of the swipe area
              child: mainContent,
            ),
          ),
          _buildAdContainer(),
        ],
      ),
    );
  }
}
