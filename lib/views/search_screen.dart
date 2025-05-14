// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/api_movie.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/widgets/skeleton_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  List<ApiMovie> movies = [];
  List<Map<String, dynamic>> searchHistory = [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingMovies = false;
  bool _isLoadingHistory = false;
  String _errorMessage = '';

  bool _isTyping = false;
  DateTime _lastTyped = DateTime.now();
  final MovieApiService _apiService = MovieApiService();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      final searchHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .orderBy('timestamp', descending: true)
          .limit(10);

      final querySnapshot = await searchHistoryRef.get();
      final history = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'keyword': data['keyword'] ?? '',
          'timestamp':
              (data['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
        };
      }).toList();

      setState(() {
        searchHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải lịch sử tìm kiếm: $e';
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _saveSearchHistory(String keyword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;
      print('Saving search history for User ID: $userId');

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email ?? '',
          'first_name': user.displayName?.split(' ').first ?? '',
          'last_name': user.displayName?.split(' ').last ?? '',
          'age': 0,
        });
      }

      final searchHistoryRef = userDocRef.collection('searchHistory');
      await searchHistoryRef.add({
        'keyword': keyword,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _loadSearchHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu lịch sử tìm kiếm: $e')),
      );
    }
  }

  Future<void> fetchSuggestions(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _errorMessage = '';
    });

    final url = Uri.parse(
      'https://phimapi.com/v1/api/tim-kiem?keyword=$keyword&page=1&sort_field=_id&sort_type=asc&limit=5',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final searchResponse = ApiSearchResponse.fromJson(data);
        setState(() {
          suggestions =
              searchResponse.movies.map((movie) => movie.title).toList();
          _isLoadingSuggestions = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải gợi ý. Mã lỗi: ${response.statusCode}';
          suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải gợi ý: $e';
        suggestions = [];
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> fetchMovies(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        movies = [];
        suggestions = [];
        _isLoadingMovies = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoadingMovies = true;
      _errorMessage = '';
      movies = [];
      suggestions = [];
    });

    final url = Uri.parse(
      'https://phimapi.com/v1/api/tim-kiem?keyword=$keyword&page=1&sort_field=_id&sort_type=asc&limit=20',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response matches expected format
        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data']['items'] != null) {
          final searchResponse = ApiSearchResponse.fromJson(data);

          setState(() {
            movies = searchResponse.movies;
            _isLoadingMovies = false;
          });

          print(
              'Loaded ${movies.length} movies, title page: ${searchResponse.titlePage}');
          if (movies.isNotEmpty) {
            print('First movie: ${movies[0].title}, slug: ${movies[0].slug}');
          }

          await _saveSearchHistory(keyword);
        } else {
          setState(() {
            _errorMessage = 'Không thể tải dữ liệu. Định dạng không hợp lệ.';
            _isLoadingMovies = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Không thể tải dữ liệu. Mã lỗi: ${response.statusCode}';
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã có lỗi xảy ra: $e';
        _isLoadingMovies = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isTyping = true;
      _lastTyped = DateTime.now();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (DateTime.now().difference(_lastTyped).inMilliseconds >= 500) {
        setState(() {
          _isTyping = false;
        });
        fetchMovies(value);
      }
    });
  }

  Future<void> _navigateToMovieDetail(ApiMovie movie) async {
    final movieModel = movie.toMovieModel();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SkeletonWidgets.movieDetailSkeleton(),
        );
      },
    );

    try {
      // Kiểm tra xem phim đã được yêu thích chưa
      bool isFavorite = false;
      try {
        final userId = await _authController.getCurrentUserId() ?? 'guest';
        if (userId != 'guest') {
          final favoriteService = Favoritemovieservice(userId);
          // Kiểm tra theo ID
          isFavorite = await favoriteService.isMovieFavorite(movieModel.id);

          // Nếu không tìm thấy theo ID, thử kiểm tra bằng slug
          if (!isFavorite && movie.slug.isNotEmpty) {
            isFavorite = await favoriteService.isMovieFavorite(movie.slug);
          }
        }
      } catch (e) {
        print('Lỗi kiểm tra trạng thái yêu thích: $e');
      }

      // Use the slug to get full movie details
      String movieSlug = movie.slug.isNotEmpty ? movie.slug : movie.id;
      print('Loading movie details for slug: $movieSlug');

      final movieDetailResult = await _apiService.getMovieDetailV3(
        movieSlug,
        fallbackModel: movieModel,
      );

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (movieDetailResult != null) {
        print('Movie detail loaded: ${movieDetailResult.movie.name}');

        // Create a more complete movie model from the movie detail
        final enhancedMovieModel = MovieModel(
          id: movieModel.id,
          title: movieDetailResult.movie.name,
          imageUrl: movieDetailResult.movie.posterUrl,
          description: movieDetailResult.movie.content,
          category: movieDetailResult.movie.status,
          genres:
              movieDetailResult.movie.category.map((cat) => cat.name).toList(),
          year: movieDetailResult.movie.year.toString(),
          isFavorite: isFavorite, // Sử dụng trạng thái yêu thích đã kiểm tra
          extraInfo: {
            'slug': movie.slug,
            'origin_name': movieDetailResult.movie.originName,
            'quality': movieDetailResult.movie.quality,
            'time': movieDetailResult.movie.time,
            'episode_current': movieDetailResult.movie.episodeCurrent,
            'episode_total': movieDetailResult.movie.episodeTotal,
            'lang': movieDetailResult.movie.lang,
            'type': movieDetailResult.movie.type,
            'hasEpisodes': movieDetailResult.hasEpisodes,
          },
        );

        // Navigate to movie detail screen with favorite status
        Navigator.pushNamed(
          context,
          '/movie_detail',
          arguments: {
            'movie': enhancedMovieModel,
            'isFavorite': isFavorite,
            'fromSearchScreen': true
          },
        );
      } else {
        // If detailed data cannot be loaded, navigate with basic model
        Navigator.pushNamed(
          context,
          '/movie_detail',
          arguments: {
            'movie': movieModel,
            'isFavorite': isFavorite,
            'fromSearchScreen': true
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      print('Error navigating to movie detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu phim: $e')),
      );

      // Still navigate to movie detail with basic model on error
      Navigator.pushNamed(
        context,
        '/movie_detail',
        arguments: {
          'movie': movieModel,
          'isFavorite': false,
          'fromSearchScreen': true
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Chặn back/swipe back
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with smaller size
              Container(
                height: 24,
                width: 24,
                margin: const EdgeInsets.only(right: 8),
              ),
              Flexible(
                child: Text(
                  movies.isNotEmpty && _controller.text.isNotEmpty
                      ? 'Kết quả tìm kiếm: ${_controller.text}'
                      : 'Tìm kiếm phim',
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search bar with gradient border
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3F54D1).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
                gradient: LinearGradient(
                  colors: [Color(0xFF3F54D1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(1.5),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                style: GoogleFonts.aBeeZee(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Tìm kiếm phim...",
                  hintStyle: GoogleFonts.aBeeZee(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              movies = [];
                              suggestions = [];
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Loading indicators
            if (_isLoadingHistory)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),

            // Search history
            if (searchHistory.isNotEmpty && !_isTyping && movies.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lịch sử tìm kiếm',
                            style: GoogleFonts.aBeeZee(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                searchHistory = [];
                              });
                            },
                            child: Text(
                              'Xóa tất cả',
                              style: GoogleFonts.aBeeZee(
                                color: Color(0xFF3F54D1),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchHistory.length,
                        itemBuilder: (context, index) {
                          final history = searchHistory[index];
                          return ListTile(
                            dense: true,
                            leading:
                                const Icon(Icons.history, color: Colors.grey),
                            title: Text(
                              history['keyword'],
                              style: GoogleFonts.aBeeZee(color: Colors.white),
                            ),
                            onTap: () {
                              _controller.text = history['keyword'];
                              _onSearchChanged(history['keyword']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestions while typing
            if (_isLoadingSuggestions && _isTyping)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (suggestions.isNotEmpty && _isTyping)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 150,
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.search, color: Colors.grey),
                      title: Text(
                        suggestions[index],
                        style: GoogleFonts.aBeeZee(color: Colors.white),
                      ),
                      onTap: () {
                        _controller.text = suggestions[index];
                        _onSearchChanged(suggestions[index]);
                      },
                    );
                  },
                ),
              ),

            // Search results
            Expanded(
              child: _isLoadingMovies
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3F54D1)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang tìm kiếm...',
                            style: GoogleFonts.aBeeZee(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: GoogleFonts.aBeeZee(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : movies.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 80,
                                    color: Color(0xFF3F54D1).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _controller.text.isEmpty
                                        ? 'Nhập từ khóa để tìm kiếm phim'
                                        : 'Không tìm thấy kết quả nào',
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    0.58, // Taller cards for more info
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movie = movies[index];

                                // Extract data from extraInfo if available
                                final extraInfo =
                                    movie.toMovieModel().extraInfo ?? {};
                                final String episodeInfo =
                                    extraInfo['episode_current']?.toString() ??
                                        '';
                                final String quality =
                                    extraInfo['quality']?.toString() ?? '';
                                final String language =
                                    extraInfo['lang']?.toString() ?? '';

                                return GestureDetector(
                                  onTap: () => _navigateToMovieDetail(movie),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Movie poster
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                movie.poster.isNotEmpty
                                                    ? Image.network(
                                                        movie.poster.startsWith(
                                                                'http')
                                                            ? movie.poster
                                                            : 'https://phimimg.com/${movie.poster}',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          color: Colors
                                                              .grey.shade800,
                                                          child: const Icon(
                                                            Icons.movie,
                                                            color: Colors.white,
                                                            size: 50,
                                                          ),
                                                        ),
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                              valueColor:
                                                                  const AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Color(
                                                                          0xFF3F54D1)),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        color: Colors
                                                            .grey.shade800,
                                                        child: const Icon(
                                                          Icons.movie,
                                                          color: Colors.white,
                                                          size: 50,
                                                        ),
                                                      ),
                                                // Play icon overlay
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                        ],
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Year tag
                                                if (movie.year.isNotEmpty)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF3F54D1)
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        movie.year,
                                                        style:
                                                            GoogleFonts.aBeeZee(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                // Quality tag
                                                if (quality.isNotEmpty)
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        quality,
                                                        style:
                                                            GoogleFonts.aBeeZee(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                // Language tag
                                                if (language.isNotEmpty)
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        language,
                                                        style:
                                                            GoogleFonts.aBeeZee(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Movie title and info
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                movie.title,
                                                style: GoogleFonts.aBeeZee(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              if (episodeInfo.isNotEmpty)
                                                Text(
                                                  episodeInfo,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: Colors.grey.shade400,
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
