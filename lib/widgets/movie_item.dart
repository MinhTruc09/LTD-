import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';

class MovieItem extends StatefulWidget {
  final MovieModel movie;
  final double width;
  final VoidCallback? onTap;

  const MovieItem({
    super.key,
    required this.movie,
    this.width = 120.0,
    this.onTap,
  });

  @override
  State<MovieItem> createState() => _MovieItemState();
}

class _MovieItemState extends State<MovieItem> {
  bool _isFavorite = false;
  late Favoritemovieservice _favoriteService;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      final userId = await _authController.getCurrentUserId() ?? 'guest';
      _favoriteService = Favoritemovieservice(userId);

      // Kiểm tra trạng thái yêu thích
      _checkFavoriteStatus();
    } catch (e) {
      print('Error initializing user in MovieItem: $e');
      _favoriteService = Favoritemovieservice('guest');
      setState(() {
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      // Kiểm tra theo ID
      bool isFavorite = await _favoriteService.isMovieFavorite(widget.movie.id);

      // Nếu không tìm thấy theo ID, thử kiểm tra bằng slug nếu có
      if (!isFavorite &&
          widget.movie.extraInfo != null &&
          widget.movie.extraInfo!.containsKey('slug')) {
        final slug = widget.movie.extraInfo!['slug'];
        if (slug != null && slug is String && slug.isNotEmpty) {
          isFavorite = await _favoriteService.isMovieFavorite(slug);
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán chiều cao tối đa cho mỗi component
    final double imageHeight =
        widget.width * 1.3; // Giảm chiều cao poster từ 1.3 xuống 1.1
    final double titleHeight = 14.0;
    final double descHeight =
        widget.movie.year.isNotEmpty || widget.movie.description.isNotEmpty
            ? 10.0
            : 0.0;
    final double totalTextHeight =
        titleHeight + descHeight + 8.0; // Giảm padding từ 8.0 xuống 4.0

    return GestureDetector(
      onTap: widget.onTap ??
          () {
            // Điều hướng đến trang chi tiết phim với thông tin yêu thích
            Navigator.pushNamed(
              context,
              '/movie_detail',
              arguments: {
                'movie': widget.movie,
                'isFavorite': _isFavorite,
                'fromSearch': true
              },
            );
          },
      child: Container(
        width: widget.width,
        margin: const EdgeInsets.symmetric(
            horizontal: 4.0,
            vertical: 0.5), // Giảm vertical margin từ 2.0 xuống 0.5
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie thumbnail với badge
            Stack(
              children: [
                // Poster
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: widget.movie.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.movie.imageUrl),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {
                              // Placeholder on error
                            },
                          )
                        : null,
                  ),
                  child: widget.movie.imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white38,
                            size: widget.width * 0.4,
                          ),
                        )
                      : null,
                ),
                // Year badge
                if (widget.movie.year.isNotEmpty)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        widget.movie.year,
                        style: GoogleFonts.aBeeZee(
                          color: Colors.white,
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite icon
                if (_isFavorite)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            // Title & subtitle
            Container(
              height: totalTextHeight,
              width: widget.width,
              padding: const EdgeInsets.only(
                  top: 3.0), // Giảm padding từ 4.0 xuống 3.0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: GoogleFonts.aBeeZee(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.movie.year.isNotEmpty ||
                      widget.movie.description.isNotEmpty)
                    Text(
                      widget.movie.year.isNotEmpty
                          ? widget.movie.year
                          : widget.movie.description,
                      style: GoogleFonts.aBeeZee(
                        color: Colors.grey[400],
                        fontSize: 8.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
