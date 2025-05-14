import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/controllers/movie_controller.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';
import 'package:movieom_app/widgets/category_filter.dart';
import 'package:movieom_app/widgets/featured_movie.dart';
import 'package:movieom_app/widgets/genre_grid.dart';
import 'package:movieom_app/widgets/movie_category_section.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';
import 'package:movieom_app/widgets/country_grid.dart';
import 'package:movieom_app/widgets/year_grid.dart';
import 'package:movieom_app/widgets/skeleton_widgets.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  final MovieController _movieController = MovieController();
  final AuthController _authController = AuthController();
  List<MovieModel> _apiMovies = [];
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _years = [];
  List<MovieModel> _genreMovies = [];
  List<MovieModel> _countryMovies = [];
  List<MovieModel> _yearMovies = [];
  Map<String, List<MovieModel>> _genreMoviesMap = {};
  Map<String, bool> _genreLoadingMap = {};

  bool _isLoading = true;
  bool _isLoadingGenreMovies = false;
  bool _isLoadingCountryMovies = false;
  bool _isLoadingYearMovies = false;
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Năm', 'Quốc gia', 'Thể loại'];
  String _selectedGenreName = '';
  String _selectedCountryName = '';
  String _selectedYearName = '';

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
    _loadCountries();
    _loadYears();
  }

  Future<void> _loadMovies() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final apiMovies = await _movieController.getAllMoviesFromApi();
      if (mounted) {
        setState(() {
          _apiMovies = apiMovies;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải phim: $e');
      if (mounted) {
        setState(() {
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

  Future<void> _loadCountries() async {
    try {
      final countries = await _movieController.getAllCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
        });
      }
    } catch (e) {
      print('Lỗi khi tải quốc gia: $e');
    }
  }

  Future<void> _loadYears() async {
    try {
      final years = await _movieController.getAllYears();
      if (mounted) {
        setState(() {
          _years = years;
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách năm: $e');
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
        final movies =
            await _movieController.getMoviesByGenreFromApi(slug, limit: 20);

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
    if (!mounted) return;
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

  Future<void> _loadMoviesByCountry(String slug, String countryName) async {
    if (!mounted) return;
    setState(() {
      _isLoadingCountryMovies = true;
      _selectedCountryName = countryName;
    });

    try {
      final movies =
          await _movieController.getMoviesByCountryFromApi(slug, limit: 20);
      if (mounted) {
        setState(() {
          _countryMovies = movies;
          _isLoadingCountryMovies = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải phim theo quốc gia: $e');
      if (mounted) {
        setState(() {
          _countryMovies = [];
          _isLoadingCountryMovies = false;
        });
      }
    }
  }

  Future<void> _loadMoviesByYear(String year, String yearName,
      {int page = 1, String category = '', String country = ''}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingYearMovies = true;
      _selectedYearName = yearName;
    });

    try {
      final movies = await _movieController.getMoviesByYearFromApi(year,
          page: page, limit: 20, category: category, country: country);
      if (mounted) {
        setState(() {
          _yearMovies = movies;
          _isLoadingYearMovies = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải phim theo năm: $e');
      if (mounted) {
        setState(() {
          _yearMovies = [];
          _isLoadingYearMovies = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Chặn back/swipe back
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.contain,
              child: MovieomLogo(fontSize: 35),
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
                if (!mounted) return;
                setState(() {
                  _selectedCategory = category;
                  if (category != 'Thể loại' &&
                      category != 'Quốc gia' &&
                      category != 'Năm') {
                    _selectedGenreName = '';
                    _genreMovies = [];
                    _selectedCountryName = '';
                    _countryMovies = [];
                    _selectedYearName = '';
                    _yearMovies = [];
                  }
                });
              },
            ),
          ),
        ),
        body: _isLoading
            ? SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SkeletonWidgets.featuredMovieSkeleton(),
                      const SizedBox(height: 24),
                      ...List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: SkeletonWidgets.movieCategorySectionSkeleton(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadMovies();
                },
                color: const Color(0xFF3F54D1),
                child: GestureDetector(
                  // Đã xoá onHorizontalDragEnd để không tự động đăng xuất khi swipe phải
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_selectedCategory == 'Thể loại')
                            _buildGenreContent()
                          else if (_selectedCategory == 'Quốc gia')
                            _buildCountryContent()
                          else if (_selectedCategory == 'Năm')
                            _buildYearContent()
                          else
                            _buildMovieContent(),
                        ],
                      ),
                    ),
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
        if (_genres.isEmpty)
          SkeletonWidgets.gridSkeleton()
        else if (_genres.isNotEmpty)
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
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_isLoadingGenreMovies)
          SkeletonWidgets.gridSkeleton()
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
                final movie = _genreMovies[index];
                return GestureDetector(
                  onTap: () async {
                    bool isFavorite = false;
                    try {
                      final userId =
                          await _authController.getCurrentUserId() ?? 'guest';
                      if (userId != 'guest') {
                        final favoriteService = Favoritemovieservice(userId);
                        isFavorite =
                            await favoriteService.isMovieFavorite(movie.id);
                        if (!isFavorite &&
                            movie.extraInfo != null &&
                            movie.extraInfo!.containsKey('slug')) {
                          final slug = movie.extraInfo!['slug'];
                          if (slug != null &&
                              slug is String &&
                              slug.isNotEmpty) {
                            isFavorite =
                                await favoriteService.isMovieFavorite(slug);
                          }
                        }
                      }
                    } catch (e) {
                      print('Lỗi kiểm tra trạng thái yêu thích: $e');
                    }
                    if (mounted) {
                      Navigator.pushNamed(
                        context,
                        '/movie_detail',
                        arguments: {
                          'movie': movie,
                          'isFavorite': isFavorite,
                        },
                      );
                    }
                  },
                  child: _buildGenreMovieItem(movie),
                );
              },
            ),
          )
        else if (_selectedGenreName.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Không tìm thấy phim nào thuộc thể loại này',
                style: GoogleFonts.aBeeZee(
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

  Widget _buildCountryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_countries.isEmpty)
          SkeletonWidgets.gridSkeleton()
        else if (_countries.isNotEmpty)
          CountryGrid(
            countries: _countries,
            onCountrySelected: (slug, name) {
              _loadMoviesByCountry(slug, name);
            },
          ),
        const SizedBox(height: 16),
        if (_selectedCountryName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phim quốc gia: $_selectedCountryName',
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_countryMovies.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      String selectedSlug = '';
                      for (var country in _countries) {
                        if (country['name'] == _selectedCountryName) {
                          selectedSlug = country['slug'] as String;
                          break;
                        }
                      }

                      if (selectedSlug.isNotEmpty) {
                        setState(() {
                          _isLoadingCountryMovies = true;
                        });

                        try {
                          final allMovies = await _movieController
                              .getMoviesByCountryFromApi(selectedSlug,
                                  limit: 64);

                          if (mounted) {
                            print(
                                'Chuyển đến màn hình xem tất cả phim quốc gia: $selectedSlug');
                            Navigator.pushNamed(
                              context,
                              '/category_movies',
                              arguments: {
                                'category':
                                    'Phim quốc gia $_selectedCountryName',
                                'movies': allMovies,
                                'genre_slug': selectedSlug
                              },
                            );
                          }
                        } catch (e) {
                          print(
                              'Lỗi khi tải tất cả phim quốc gia $_selectedCountryName: $e');
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoadingCountryMovies = false;
                            });
                          }
                        }
                      }
                    },
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.aBeeZee(
                        color: const Color(0xFF3F54D1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (_isLoadingCountryMovies)
          SkeletonWidgets.gridSkeleton()
        else if (_countryMovies.isNotEmpty)
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
              itemCount: _countryMovies.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildGenreMovieItem(_countryMovies[index]);
              },
            ),
          )
        else if (_selectedCountryName.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Không tìm thấy phim nào thuộc quốc gia này',
                style: GoogleFonts.aBeeZee(
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

  Widget _buildYearContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_years.isEmpty)
          SkeletonWidgets.gridSkeleton()
        else if (_years.isNotEmpty)
          YearGrid(
            years: _years,
            onYearSelected: (year, name) {
              _loadMoviesByYear(year, name);
            },
          )
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Không thể tải danh sách năm phát hành',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (_selectedYearName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phim năm: $_selectedYearName',
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_yearMovies.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      if (_selectedYearName.isNotEmpty) {
                        setState(() {
                          _isLoadingYearMovies = true;
                        });

                        try {
                          final allMovies = await _movieController
                              .getMoviesByYearFromApi(_selectedYearName,
                                  limit: 64);

                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              '/category_movies',
                              arguments: {
                                'category': 'Phim năm $_selectedYearName',
                                'movies': allMovies,
                                'genre_slug': _selectedYearName
                              },
                            );
                          }
                        } catch (e) {
                          print(
                              'Lỗi khi tải tất cả phim năm $_selectedYearName: $e');
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoadingYearMovies = false;
                            });
                          }
                        }
                      }
                    },
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.aBeeZee(
                        color: const Color(0xFF3F54D1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (_isLoadingYearMovies)
          SkeletonWidgets.gridSkeleton()
        else if (_yearMovies.isNotEmpty)
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
              itemCount: _yearMovies.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildGenreMovieItem(_yearMovies[index]);
              },
            ),
          )
        else if (_selectedYearName.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Không tìm thấy phim nào trong năm này',
                style: GoogleFonts.aBeeZee(
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

  Widget _buildMovieContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_apiMovies.isEmpty)
          SkeletonWidgets.featuredMovieSkeleton()
        else if (_apiMovies.isNotEmpty)
          FeaturedMovie(
            movie: _apiMovies[0],
            onTap: () async {
              bool isFavorite = false;
              try {
                final userId =
                    await _authController.getCurrentUserId() ?? 'guest';
                if (userId != 'guest') {
                  final favoriteService = Favoritemovieservice(userId);
                  isFavorite =
                      await favoriteService.isMovieFavorite(_apiMovies[0].id);

                  if (!isFavorite &&
                      _apiMovies[0].extraInfo != null &&
                      _apiMovies[0].extraInfo!.containsKey('slug')) {
                    final slug = _apiMovies[0].extraInfo!['slug'];
                    if (slug != null && slug is String && slug.isNotEmpty) {
                      isFavorite = await favoriteService.isMovieFavorite(slug);
                    }
                  }
                }
              } catch (e) {
                print('Lỗi kiểm tra yêu thích trong trang chủ: $e');
              }

              if (mounted) {
                Navigator.pushNamed(
                  context,
                  '/movie_detail',
                  arguments: {
                    'movie': _apiMovies[0],
                    'isFavorite': isFavorite,
                    'fromHomeScreen': true
                  },
                );
              }
            },
          )
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Không có phim nào để hiển thị',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        if (_apiMovies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
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
          onViewAll: () async {
            if (mounted) {
              setState(() {
                _isLoadingGenreMovies = true;
              });

              try {
                final allMovies = await _movieController
                    .getMoviesByGenreFromApi(slug, limit: 64);

                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    '/category_movies',
                    arguments: {
                      'category': 'Phim $name',
                      'movies': allMovies,
                      'genre_slug': slug
                    },
                  );
                }
              } catch (e) {
                print('Lỗi khi tải tất cả phim thể loại $name: $e');
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoadingGenreMovies = false;
                  });
                }
              }
            }
          },
        ));

        if (i < orderedGenres.length - 1) {
          sections.add(Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Divider(
              color: Colors.white,
              thickness: 2.0,
            ),
          ));
        }
      }
    }

    return sections;
  }

  Widget _buildLoadingSectionPlaceholder(String message) {
    return SkeletonWidgets.movieCategorySectionSkeleton();
  }

  Widget _buildGenreMovieItem(MovieModel movie) {
    return GestureDetector(
      onTap: () async {
        bool isFavorite = false;
        try {
          final userId = await _authController.getCurrentUserId() ?? 'guest';
          if (userId != 'guest') {
            final favoriteService = Favoritemovieservice(userId);
            isFavorite = await favoriteService.isMovieFavorite(movie.id);
            if (!isFavorite &&
                movie.extraInfo != null &&
                movie.extraInfo!.containsKey('slug')) {
              final slug = movie.extraInfo!['slug'];
              if (slug != null && slug is String && slug.isNotEmpty) {
                isFavorite = await favoriteService.isMovieFavorite(slug);
              }
            }
          }
        } catch (e) {
          print('Lỗi kiểm tra trạng thái yêu thích: $e');
        }
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/movie_detail',
            arguments: {
              'movie': movie,
              'isFavorite': isFavorite,
            },
          );
        }
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
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 14,
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
                style: GoogleFonts.aBeeZee(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http')) {
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
          print('Lỗi tải hình ảnh từ URL: $imageUrl, lỗi: $error');
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
      print('imageUrl không hợp lệ hoặc rỗng: $imageUrl');
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
}
