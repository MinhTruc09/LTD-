import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';
import 'package:movieom_app/services/favoritemovieservice.dart';
import 'package:movieom_app/controllers/auth_controller.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isLoading = true;
  MovieModel? movie;
  Map<String, dynamic>? movieDetails;
  String? errorMessage;
  final MovieApiService _apiService = MovieApiService();
  late Favoritemovieservice _favoriteService;
  final AuthController _authController = AuthController();
  bool isFavorite = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userId = await _authController.getCurrentUserId() ?? 'guest';
    setState(() {
      _currentUserId = userId;
      _favoriteService = Favoritemovieservice(userId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieDetails();
    });
  }

  Future<void> _loadMovieDetails() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is MovieModel) {
      setState(() {
        movie = args;
      });

      try {
        isFavorite = await _favoriteService.isFavorite(args);
        final details = await _apiService.getMovieDetail(movie!.id);

        if (details != null) {
          setState(() {
            movieDetails = {
              'title': details.title,
              'poster_path': details.imageUrl,
              'overview': details.description,
              'release_date': details.year,
              'genres': details.genres.map((genre) => {'name': genre}).toList(),
            };
            isLoading = false;
          });
        } else {
          setState(() {
            movieDetails = {
              'title': movie!.title,
              'poster_path': movie!.imageUrl,
              'overview': movie!.description,
              'release_date': movie!.year,
              'genres': movie!.genres.map((genre) => {'name': genre}).toList(),
              'status': 'Released',
              'vote_average': 0.0,
            };
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Invalid movie data';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (movie == null) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        await _favoriteService.addFavorite(movie!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      } else {
        await _favoriteService.removeFavorite(movie!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (!mounted) return;
      setState(() {
        isFavorite = !isFavorite; // Hoàn tác nếu có lỗi
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error: ${e.toString().contains('No internet connection') ? 'No internet connection. Please check your network.' : 'Could not update favorites. Please try again.'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          movieDetails?['title'] ?? 'Movie Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F54D1)),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                )
              : _buildMovieDetails(),
    );
  }

  Widget _buildMovieDetails() {
    final posterPath = movieDetails?['poster_path'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            child: posterPath != null && posterPath.isNotEmpty
                ? _buildImage(posterPath, double.infinity, 250)
                : const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.white38,
                      size: 80,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieDetails?['title'] ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (movie?.year != null && movie!.year.isNotEmpty)
                  Text(
                    movie!.year,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildGenreChips(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Overview',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movieDetails?['overview'] ?? 'No overview available',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    label: Text(
                      isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      style: GoogleFonts.poppins(),
                    ),
                    onPressed: _toggleFavorite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F54D1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGenreChips() {
    final genres = movieDetails?['genres'];
    if (genres != null && genres.isNotEmpty) {
      return List<Widget>.from(
        genres.map(
          (genre) => Chip(
            label: Text(
              genre['name'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF3F54D1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      );
    } else if (movie != null && movie!.genres.isNotEmpty) {
      return List<Widget>.from(
        movie!.genres.map(
          (genre) => Chip(
            label: Text(
              genre,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF3F54D1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      );
    }
    return [];
  }

  Widget _buildImage(String imageUrl, double width, double height) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
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
            width: width,
            height: height,
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
        width: width,
        height: height,
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
