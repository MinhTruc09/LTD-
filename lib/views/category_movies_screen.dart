import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/controllers/movie_controller.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';

class CategoryMoviesScreen extends StatefulWidget {
  final String category;
  final List<MovieModel> movies;
  final String? genreSlug;

  const CategoryMoviesScreen({
    super.key,
    required this.category,
    required this.movies,
    this.genreSlug,
  });

  @override
  State<CategoryMoviesScreen> createState() => _CategoryMoviesScreenState();
}

class _CategoryMoviesScreenState extends State<CategoryMoviesScreen> {
  final AuthController _authController = AuthController();
  final MovieController _movieController = MovieController();
  late List<MovieModel> _displayedMovies;
  bool _isLoading = false;
  bool _canLoadMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _displayedMovies = List.from(widget.movies);
    
    _canLoadMore = widget.genreSlug != null && widget.movies.length >= 60;
    
    // Log thông tin debug
    print('CategoryMoviesScreen được tạo với:');
    print('- Danh mục: ${widget.category}');
    print('- Số lượng phim: ${widget.movies.length}');
    print('- Genre Slug: ${widget.genreSlug}');
    print('- Có thể tải thêm: $_canLoadMore');
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500 &&
        !_isLoading &&
        _canLoadMore) {
      _loadMoreMovies();
    }
  }

  Future<void> _loadMoreMovies() async {
    if (!_canLoadMore || _isLoading || widget.genreSlug == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      _currentPage++;
      // Kiểm tra xem genreSlug có phải là năm hay không (nếu là số)
      if (widget.genreSlug!.contains(RegExp(r'^[0-9]{4}$'))) {
        // Đây là slug năm
        final moreMovies = await _movieController.getMoviesByYearFromApi(
          widget.genreSlug!,
          page: _currentPage,
          limit: 64
        );
        
        if (moreMovies.isEmpty) {
          setState(() {
            _canLoadMore = false;
            _isLoading = false;
          });
          return;
        }
        
        final newMovies = moreMovies.where((newMovie) => 
          !_displayedMovies.any((existingMovie) => existingMovie.id == newMovie.id)
        ).toList();
        
        if (mounted) {
          setState(() {
            _displayedMovies.addAll(newMovies);
            _isLoading = false;
            _canLoadMore = moreMovies.length >= 60;
          });
        }
      } 
      // Kiểm tra xem genreSlug có trong danh sách quốc gia hay không
      else if (['viet-nam', 'han-quoc', 'thai-lan', 'au-my', 'trung-quoc', 'hong-kong', 'nhat-ban', 'dai-loan', 'an-do'].contains(widget.genreSlug!)) {
        // Đây là slug quốc gia
        final moreMovies = await _movieController.getMoviesByCountryFromApi(
          widget.genreSlug!,
          page: _currentPage,
          limit: 64
        );
        
        if (moreMovies.isEmpty) {
          setState(() {
            _canLoadMore = false;
            _isLoading = false;
          });
          return;
        }
        
        final newMovies = moreMovies.where((newMovie) => 
          !_displayedMovies.any((existingMovie) => existingMovie.id == newMovie.id)
        ).toList();
        
        if (mounted) {
          setState(() {
            _displayedMovies.addAll(newMovies);
            _isLoading = false;
            _canLoadMore = moreMovies.length >= 60;
          });
        }
      }
      else {
        // Mặc định là slug thể loại phim
        final moreMovies = await _movieController.getMoviesByGenreFromApi(
          widget.genreSlug!,
          page: _currentPage,
          limit: 64
        );
        
        if (moreMovies.isEmpty) {
          setState(() {
            _canLoadMore = false;
            _isLoading = false;
          });
          return;
        }
        
        final newMovies = moreMovies.where((newMovie) => 
          !_displayedMovies.any((existingMovie) => existingMovie.id == newMovie.id)
        ).toList();
        
        if (mounted) {
          setState(() {
            _displayedMovies.addAll(newMovies);
            _isLoading = false;
            _canLoadMore = moreMovies.length >= 60;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải thêm phim: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        foregroundColor: Colors.white,
        title: Text(
          widget.category,
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _displayedMovies.isEmpty
          ? Center(
              child: Text(
                'Không có phim nào trong danh mục này',
                style: GoogleFonts.aBeeZee(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _displayedMovies[index];
                      return _buildMovieItem(movie);
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMovieItem(MovieModel movie) {
    return GestureDetector(
      onTap: () async {
        bool isFavorite = false;
        try {
          final userId = await _authController.getCurrentUserId() ?? 'guest';
          if (userId != 'guest') {
            final favoriteService = Favoritemovieservice(userId);
            isFavorite = await favoriteService.isMovieFavorite(movie.id);
            
            if (!isFavorite && movie.extraInfo != null && movie.extraInfo!.containsKey('slug')) {
              final slug = movie.extraInfo!['slug'];
              if (slug != null && slug is String && slug.isNotEmpty) {
                isFavorite = await favoriteService.isMovieFavorite(slug);
              }
            }
          }
        } catch (e) {
          print('Lỗi kiểm tra yêu thích: $e');
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
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
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