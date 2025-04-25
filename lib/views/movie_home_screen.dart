// movie_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/controllers/movie_controller.dart';
import 'package:movieom_app/widgets/category_filter.dart';
import 'package:movieom_app/widgets/featured_movie.dart';
import 'package:movieom_app/widgets/genre_grid.dart';
import 'package:movieom_app/widgets/movie_category_section.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  final MovieController _movieController = MovieController();
  final AuthController _authController = AuthController();
  List<MovieModel> _allMovies = [];
  List<MovieModel> _apiMovies = [];
  List<Map<String, dynamic>> _genres = [];
  List<MovieModel> _genreMovies = [];

  Map<String, List<MovieModel>> _genreMoviesMap = {};
  Map<String, bool> _genreLoadingMap = {};

  bool _isLoading = true;
  bool _isLoadingGenreMovies = false;
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Xu hướng',
    'Diễn viên',
    'Thể loại'
  ];
  String _selectedGenreName = '';

  final int _maxGenresOnHome = 5;
  final List<String> _popularGenreSlugs = [
    'hanh-dong',
    'tinh-cam',
    'kinh-di',
    'vien-tuong',
    'tre-em'
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadGenres();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiMovies = await _movieController.getAllMoviesFromApi();
      final mockMovies = _movieController.getMockMovies();

      if (mounted) {
        setState(() {
          _apiMovies = apiMovies;
          _allMovies = apiMovies.isNotEmpty ? apiMovies : mockMovies;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải phim: $e');
      if (mounted) {
        setState(() {
          _allMovies = _movieController.getMockMovies();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _movieController.getAllGenres();
      if (mounted) {
        setState(() {
          _genres = genres;
          _loadMoviesByGenres();
        });
      }
    } catch (e) {
      print('Lỗi khi tải thể loại: $e');
    }
  }

  Future<void> _loadMoviesByGenres() async {
    List<Map<String, dynamic>> genresToLoad = [];

    for (var popularSlug in _popularGenreSlugs) {
      final genre = _genres.firstWhere((g) => g['slug'] == popularSlug,
          orElse: () => <String, dynamic>{});
      if (genre.isNotEmpty) {
        genresToLoad.add(genre);
      }
    }

    if (genresToLoad.length < _maxGenresOnHome) {
      final remainingGenres = _genres
          .where((g) => !_popularGenreSlugs.contains(g['slug']))
          .take(_maxGenresOnHome - genresToLoad.length)
          .toList();
      genresToLoad.addAll(remainingGenres);
    }

    genresToLoad = genresToLoad.take(_maxGenresOnHome).toList();

    for (var genre in genresToLoad) {
      _genreLoadingMap[genre['slug']] = true;
    }

    if (mounted) setState(() {});

    for (var genre in genresToLoad) {
      try {
        final slug = genre['slug'];
        final movies = await _movieController.getMoviesByGenreFromApi(slug);

        if (mounted) {
          setState(() {
            _genreMoviesMap[slug] = movies;
            _genreLoadingMap[slug] = false;
          });
        }
      } catch (e) {
        print('Lỗi khi tải phim thể loại ${genre['name']}: $e');
        if (mounted) {
          setState(() {
            _genreLoadingMap[genre['slug']] = false;
          });
        }
      }
    }
  }

  Future<void> _loadMoviesByGenre(String slug, String genreName) async {
    setState(() {
      _isLoadingGenreMovies = true;
      _selectedGenreName = genreName;
    });

    try {
      final movies = await _movieController.getMoviesByGenreFromApi(slug);
      if (mounted) {
        setState(() {
          _genreMovies = movies;
          _isLoadingGenreMovies = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải phim theo thể loại: $e');
      if (mounted) {
        setState(() {
          _genreMovies = [];
          _isLoadingGenreMovies = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: 48,
          child: FittedBox(
            fit: BoxFit.contain,
            child: MovieomLogo(fontSize: 32),
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: CategoryFilter(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                if (category != 'Thể loại') {
                  _selectedGenreName = '';
                  _genreMovies = [];
                }
              });
            },
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadMovies();
              },
              color: const Color(0xFF3F54D1),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedCategory == 'Thể loại')
                        _buildGenreContent()
                      else
                        _buildMovieContent(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGenreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_genres.isNotEmpty)
          GenreGrid(
            genres: _genres,
            onGenreSelected: (slug, name) {
              _loadMoviesByGenre(slug, name);
            },
          ),
        const SizedBox(height: 16),
        if (_selectedGenreName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: Text(
              'Phim thể loại: $_selectedGenreName',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_isLoadingGenreMovies)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
              ),
            ),
          )
        else if (_genreMovies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: _genreMovies.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildGenreMovieItem(_genreMovies[index]);
              },
            ),
          )
        else if (_selectedGenreName.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Không tìm thấy phim nào thuộc thể loại này',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildGenreMovieItem(MovieModel movie) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/movie_detail',
          arguments: movie,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(movie.imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              movie.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (movie.year.isNotEmpty)
            SizedBox(
              height: 15,
              child: Text(
                movie.year,
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Lỗi tải hình ảnh: $error');
          return Container(
            color: Colors.grey[800],
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const Icon(
          Icons.movie,
          color: Colors.white38,
          size: 40,
        ),
      );
    }
  }

  Widget _buildMovieContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_apiMovies.isNotEmpty)
          FeaturedMovie(
            movie: _apiMovies[0],
            onTap: () {
              Navigator.pushNamed(
                context,
                '/movie_detail',
                arguments: _apiMovies[0],
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.only(
              top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
          child: Divider(
            color: Colors.grey[800],
            thickness: 1.0,
          ),
        ),
        if (_apiMovies.length > 1)
          MovieCategorySection(
            title: 'Phim Mới Cập Nhật',
            movies: _apiMovies.skip(1).take(10).toList(),
            onViewAll: () {
              Navigator.pushNamed(
                context,
                '/category_movies',
                arguments: {
                  'category': 'Phim Mới',
                  'movies': _apiMovies,
                },
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            color: Colors.grey[800],
            thickness: 1.0,
          ),
        ),
        ..._buildGenreMovieSections(),
        const SizedBox(height: 80),
      ],
    );
  }

  List<Widget> _buildGenreMovieSections() {
    List<Widget> sections = [];

    List<Map<String, dynamic>> orderedGenres = [];

    for (var popularSlug in _popularGenreSlugs) {
      final genre = _genres.firstWhere((g) => g['slug'] == popularSlug,
          orElse: () => <String, dynamic>{});
      if (genre.isNotEmpty && _genreMoviesMap.containsKey(popularSlug)) {
        orderedGenres.add(genre);
      }
    }

    for (var genre in _genres) {
      if (!_popularGenreSlugs.contains(genre['slug']) &&
          _genreMoviesMap.containsKey(genre['slug'])) {
        orderedGenres.add(genre);
      }
    }

    orderedGenres = orderedGenres.take(_maxGenresOnHome).toList();

    for (var i = 0; i < orderedGenres.length; i++) {
      final genre = orderedGenres[i];
      final slug = genre['slug'];
      final name = genre['name'];

      if (_genreLoadingMap[slug] == true) {
        sections.add(_buildLoadingSectionPlaceholder('Đang tải phim $name...'));
        continue;
      }

      final movies = _genreMoviesMap[slug] ?? [];
      if (movies.isNotEmpty) {
        sections.add(MovieCategorySection(
          title: 'Phim $name',
          movies: movies,
          onViewAll: () {
            Navigator.pushNamed(
              context,
              '/category_movies',
              arguments: {
                'category': name,
                'movies': movies,
              },
            );
          },
        ));

        if (i < orderedGenres.length - 1) {
          sections.add(Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Divider(
              color: Colors.grey[800],
              thickness: 1.0,
            ),
          ));
        }
      }
    }

    return sections;
  }

  Widget _buildLoadingSectionPlaceholder(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
