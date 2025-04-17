import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieDetails();
    });
  }

  Future<void> _loadMovieDetails() async {
    // Get the movie passed as argument
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is MovieModel) {
      setState(() {
        movie = args;
      });

      try {
        // Try to get additional details if available
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
          // If API doesn't return details, use the information from the movie model
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
          // Hero image (backdrop or poster enlarged)
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
                // Title and year
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

                // Genres
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildGenreChips(),
                ),

                const SizedBox(height: 24),

                // Overview
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

                // Add to favorites button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite_border),
                    label: Text(
                      'Add to favorites',
                      style: GoogleFonts.poppins(),
                    ),
                    onPressed: () {
                      // TODO: Implement add to favorites functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites')),
                      );
                    },
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
