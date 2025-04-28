import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieom_app/widgets/Appbarfavorite.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'dart:async';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  late List<bool> isPlayingList;
  List<MovieModel> favoriteMovies = [];
  late Favoritemovieservice _favoriteService;
  final AuthController _authController = AuthController();
  String _currentUserId = '';
  StreamSubscription<String?>? _userIdSubscription;
  bool _isLoading = true;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeUser();
    _userIdSubscription = _authController.userIdStream.listen((newUserId) {
      if (newUserId != _currentUserId) {
        _onAccountChanged(newUserId);
      }
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newUserId = ModalRoute.of(context)?.settings.arguments as String?;
    if (newUserId != null && newUserId != _currentUserId) {
      _onAccountChanged(newUserId);
    }
  }

  @override
  void dispose() {
    _userIdSubscription?.cancel();
    _authController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final userId = await _authController.getCurrentUserId() ?? 'guest';
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _favoriteService = Favoritemovieservice(userId);
      _isLoading = true;
    });
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoriteService.getFavorites();
      if (!mounted) return;
      setState(() {
        favoriteMovies = favorites;
        isPlayingList = List.generate(favoriteMovies.length, (_) => false);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      if (!mounted) return;
      setState(() {
        favoriteMovies = [];
        isPlayingList = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách yêu thích: $e')),
      );
    }
  }

  Future<void> _onAccountChanged(String newUserId) async {
    final userIdToUse = newUserId.isEmpty ? 'guest' : newUserId;
    if (!mounted) return;
    setState(() {
      _currentUserId = userIdToUse;
      _favoriteService = Favoritemovieservice(userIdToUse);
      _isLoading = true;
    });
    await _loadFavorites();
  }

  Future<void> _removeFavorite(MovieModel movie) async {
    try {
      await _favoriteService.removeFavorite(movie);
      setState(() {
        favoriteMovies.removeWhere((m) => m.id == movie.id);
        isPlayingList = List.generate(favoriteMovies.length, (_) => false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${movie.title}" khỏi yêu thích',style: GoogleFonts.aBeeZee(color: Colors.white),),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF3F54D1),
          action: SnackBarAction(
            label: 'Hoàn tác',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await _favoriteService.addFavorite(movie);
                _loadFavorites();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi hoàn tác: $e')),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa phim: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Appbarfavorite(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
                    ),
                  )
                : _buildFavoriteContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteContent() {
    if (favoriteMovies.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: const Color(0xFF3F54D1),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: favoriteMovies.length,
          itemBuilder: (context, index) {
            // Tạo hiệu ứng delay cho từng item
            Future.delayed(Duration(milliseconds: 100 * index), () {
              if (_animationController.status != AnimationStatus.completed) {
                _animationController.forward();
              }
            });

            final movie = favoriteMovies[index];
            return _buildMovieCard(movie, index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 24),
          Text(
            'Bạn chưa có phim yêu thích',
            style: GoogleFonts.aBeeZee(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm phim yêu thích từ trang chi tiết phim',
            style: GoogleFonts.aBeeZee(
              color: Colors.grey[400],
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label:  Text('Tìm phim ngay',style: GoogleFonts.aBeeZee(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w700),),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F54D1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shadowColor: const Color(0xFF3F54D1).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF3F54D1).withOpacity(0.3),
          width: 3,
        ),
      ),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/movie_detail',
          arguments: {
            'movie': movie,
            'isFavorite': true,
            'fromFavoriteScreen': true
          },
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster with Gradient Overlay
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _buildMovieImage(movie),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Year badge
                  if (movie.year.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3F54D1), width: 1.5),
                        ),
                        child: Text(
                          movie.year,
                          style: GoogleFonts.aBeeZee(
                            color: Color(0xFF3F54D1),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Title positioned at bottom of poster
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      movie.title,
                      style: GoogleFonts.aBeeZee(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Movie Info and Actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genres
                  if (movie.genres.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: movie.genres
                          .take(3)
                          .map((genre) => _buildGenreChip(genre))
                          .toList(),
                    ),

                  const SizedBox(height: 12),

                  // Description
                  if (movie.description.isNotEmpty)
                    Text(
                      movie.description,
                      style: GoogleFonts.aBeeZee(
                        color: Colors.grey[300],
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Play button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Xem phim'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3F54D1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/movie_detail',
                              arguments: {
                                'movie': movie,
                                'isFavorite': true,
                                'fromFavoriteScreen': true
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Remove button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 28),
                        color: Colors.white,
                        tooltip: 'Xóa khỏi yêu thích',
                        onPressed: () => _showRemoveConfirmation(movie),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3F54D1).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3F54D1).withOpacity(0.5),
        ),
      ),
      child: Text(
        genre,
        style: GoogleFonts.aBeeZee(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMovieImage(MovieModel movie) {
    return CachedNetworkImage(
      imageUrl: movie.imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie, color: Colors.white54, size: 50),
              const SizedBox(height: 8),
              Text(
                movie.title,
                style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveConfirmation(MovieModel movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Xóa khỏi danh sách yêu thích?',
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${movie.title}" khỏi danh sách phim yêu thích?',
          style: GoogleFonts.aBeeZee(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text(
              'Hủy',
              style: GoogleFonts.aBeeZee(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Xóa',
              style: GoogleFonts.aBeeZee(color: Color(0xFF3F54D1)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(movie);
            },
          ),
        ],
      ),
    );
  }
}
