// lib/views/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/Entity/movie_detail_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';
import 'package:movieom_app/views/video_player_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isLoading = true;
  MovieModel? movie;
  MovieDetailModel? movieDetail;
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
        isLoading = true;
      });

      try {
        // Xác định slug từ thông tin phim
        String movieSlug = '';
        if (movie!.extraInfo != null && movie!.extraInfo!.containsKey('slug')) {
          movieSlug = movie!.extraInfo!['slug'];
        } else if (movie!.id.isNotEmpty) {
          movieSlug = movie!.id;
        }

        print('Đang tải chi tiết phim với slug/id: $movieSlug');

        // Sử dụng service để tải dữ liệu phim
        final movieDetailResult = await _apiService.getMovieDetailV3(
          movieSlug,
          fallbackModel: movie,
        );

        if (movieDetailResult != null) {
          setState(() {
            movieDetail = movieDetailResult;
            isLoading = false;
          });

          // Debug thông tin hiển thị
          print('Loaded movie detail:');
          print('Title: ${movieDetail?.movie.name}');
          print('Overview available: ${movieDetail?.movie.content.isNotEmpty}');
          print('Actors available: ${movieDetail?.movie.actor.length ?? 0}');
          print(
              'Overview: ${movieDetail?.movie.content.substring(0, min(50, movieDetail?.movie.content.length ?? 0))}...');

          // Additional debug info
          print('Is series movie: ${movieDetail?.isSeriesMovie}');
          print('Has episodes: ${movieDetail?.hasEpisodes}');
          if (movieDetail?.hasEpisodes == true) {
            print('Episode servers: ${movieDetail?.episodes.length}');
            for (int i = 0; i < (movieDetail?.episodes.length ?? 0); i++) {
              print('Server ${i + 1}: ${movieDetail?.episodes[i].serverName}');
              print(
                  'Episodes count: ${movieDetail?.episodes[i].serverData.length}');
            }
          } else {
            print('No episodes found!');
          }
        } else {
          throw Exception('Failed to load movie details');
        }
      } catch (e) {
        print('Error loading movie details: $e');
        setState(() {
          // Hiển thị thông báo lỗi
          errorMessage = 'Không thể tải thông tin phim: ${e.toString()}';
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
          movieDetail?.movie.name ?? 'Chi tiết phim',
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
      bottomNavigationBar:
      isLoading || errorMessage != null ? null : _buildBottomActionBar(),
    );
  }

  Widget _buildBottomActionBar() {
    if (movieDetail == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SafeArea(
        child: Row(
          children: [
            // Nút Yêu thích
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                label: Text(
                  'Yêu thích',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F54D1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm vào yêu thích')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Nút Xem phim
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'Xem phim',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _handleWatchMovie,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieDetails() {
    if (movieDetail == null || movie == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final posterUrl = movieDetail!.movie.posterUrl.isNotEmpty
        ? movieDetail!.movie.posterUrl
        : movie!.imageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with gradient overlay and trailer button
          _buildHeroImage(posterUrl),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie title section
                _buildTitleSection(),

                const SizedBox(height: 16),

                // Key info badges section
                _buildKeyInfoBadges(),

                const SizedBox(height: 24),

                // Content/overview section - Luôn hiển thị, kể cả khi không có nội dung
                _buildContentSection(),

                const SizedBox(height: 24),

                // Technical details card
                _buildTechnicalDetails(),

                const SizedBox(height: 24),

                // Episode selector - should always appear if episodes exist
                if (movieDetail!.hasEpisodes) _buildEpisodeSelector(),

                // Cast and crew section
                if (movieDetail!.hasActors || movieDetail!.hasDirectors)
                  _buildCastAndCrew(),

                // Padding ở dưới cùng để tránh bị che bởi bottom action bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hero image with gradient overlay and trailer button
  Widget _buildHeroImage(String posterUrl) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
          ),
          child: posterUrl.isNotEmpty
              ? _buildImage(posterUrl, double.infinity, 250)
              : const Center(
            child: Icon(
              Icons.movie,
              color: Colors.white38,
              size: 80,
            ),
          ),
        ),
        // Overlay gradient for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black,
                ],
              ),
            ),
          ),
        ),
        // Trailer button if available
        if (movieDetail!.hasTrailer)
          Positioned(
            right: 16,
            top: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                'Trailer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Navigate to trailer using video player
                final trailerUrl = movieDetail!.movie.trailerUrl;
                if (trailerUrl.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/video_player',
                    arguments: {
                      'videoUrl': trailerUrl,
                      'title': 'Trailer: ${movieDetail!.movie.name}',
                      'isEmbed': trailerUrl.contains('embed') ||
                          trailerUrl.contains('player'),
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không có trailer')),
                  );
                }
              },
            ),
          ),
      ],
    );
  }

  // Title section with original name
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movie title
        Text(
          movieDetail!.movie.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Original title if available
        if (movieDetail!.movie.originName.isNotEmpty)
          Text(
            movieDetail!.movie.originName,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  // Key info badges section (quality, language, etc.)
  Widget _buildKeyInfoBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Quality badge
        _buildInfoBadge(
          movieDetail!.movie.quality,
          Icons.high_quality,
          Colors.green,
        ),

        // Language badge
        _buildInfoBadge(
          movieDetail!.movie.lang,
          Icons.language,
          Colors.blue,
        ),

        // Time/Duration badge
        if (movieDetail!.movie.time.isNotEmpty)
          _buildInfoBadge(
            movieDetail!.movie.time,
            Icons.timer,
            Colors.purple,
          ),

        // Year badge
        if (movieDetail!.movie.year != 0)
          _buildInfoBadge(
            movieDetail!.movie.year.toString(),
            Icons.calendar_today,
            Colors.amber,
          ),

        // Status badge (ongoing/completed)
        _buildInfoBadge(
          movieDetail!.displayStatus,
          Icons.info_outline,
          Colors.teal,
        ),

        // Type badge (series/movie)
        _buildInfoBadge(
          movieDetail!.displayType,
          Icons.movie_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  // Content/Overview section
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung phim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movieDetail!.movie.content.isNotEmpty
              ? movieDetail!.movie.content
              : 'Không có mô tả cho phim này.',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Technical details card with genre, duration, production company and language
  Widget _buildTechnicalDetails() {
    final movie = movieDetail!.movie;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin kỹ thuật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Thể loại
        if (movie.category.isNotEmpty)
          _buildDetailRow(
              'Thể loại:', movie.category.map((c) => c.name).join(', ')),

        // Thời lượng
        if (movie.time.isNotEmpty) _buildDetailRow('Thời lượng:', movie.time),

        // Năm phát hành
        if (movie.year > 0)
          _buildDetailRow('Năm phát hành:', movie.year.toString()),

        // Ngôn ngữ
        _buildDetailRow('Ngôn ngữ:', movie.lang),

        // Chất lượng
        if (movie.quality.isNotEmpty)
          _buildDetailRow('Chất lượng:', movie.quality),

        // Công ty sản xuất
        if (movie.productionCompanies != null &&
            movie.productionCompanies!.isNotEmpty)
          _buildDetailRow(
              'Công ty sản xuất:', movie.productionCompanies!.join(', ')),

        // Ngôn ngữ gốc
        if (movie.spokenLanguages != null && movie.spokenLanguages!.isNotEmpty)
          _buildDetailRow('Ngôn ngữ gốc:', movie.spokenLanguages!.join(', ')),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build episode selector
  Widget _buildEpisodeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF3F54D1).withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách tập phim',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Server tabs if multiple servers
          if (movieDetail!.episodes.length > 1)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movieDetail!.episodes.length,
                itemBuilder: (context, index) {
                  final server = movieDetail!.episodes[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Show episodes for this server
                        setState(() {
                          _selectedServerIndex = index;
                          _selectedEpisodeIndex = 0; // Reset episode selection
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedServerIndex == index
                            ? const Color(0xFF3F54D1)
                            : Colors.grey[800],
                        foregroundColor: Colors.white,
                        elevation: _selectedServerIndex == index ? 6 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(server.serverName),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Episode grid
          if (movieDetail!.episodes.isNotEmpty) _buildEpisodeGrid(),
        ],
      ),
    );
  }

  // Selected server index
  int _selectedServerIndex = 0;
  // Selected episode index
  int _selectedEpisodeIndex = 0;

  // Method to build episode grid
  Widget _buildEpisodeGrid() {
    if (_selectedServerIndex >= movieDetail!.episodes.length) {
      return const Center(
        child: Text(
          'Không có tập phim',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final episodes = movieDetail!.episodes[_selectedServerIndex].serverData;

    if (episodes.isEmpty) {
      return const Center(
        child: Text(
          'Không có tập phim',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show episode count information
        Text(
          'Tổng số: ${episodes.length} tập${episodes.length > 0 ? " (Chọn tập ${_selectedEpisodeIndex + 1} - ${episodes[_selectedEpisodeIndex].name})" : ""}',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        // Show server information
        Text(
          'Server: ${movieDetail!.episodes[_selectedServerIndex].serverName}',
          style: GoogleFonts.poppins(
            color: Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Episode grid with improved styling
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            final isSelected = _selectedEpisodeIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEpisodeIndex = index;
                });

                // Play this episode
                _playEpisode(episode);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red
                      : const Color(0xFF3F54D1).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    isSelected ? Colors.red.shade300 : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    episode.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Method to play an episode
  void _playEpisode(EpisodeData episode) {
    // Debug episode data
    print('Đang xử lý episode: ${episode.name}');
    print('Link M3U8: ${episode.linkM3u8}');
    print('Link Embed: ${episode.linkEmbed}');

    try {
      // Lấy danh sách tất cả các tập từ tất cả các server
      final allEpisodes = movieDetail?.episodes
          .asMap()
          .entries
          .map((entry) {
        final serverIndex = entry.key;
        final server = entry.value;
        return server.serverData.asMap().entries.map((e) {
          final episodeIndex = e.key;
          final ep = e.value;
          return {
            'name': ep.name,
            'link_m3u8': ep.linkM3u8,
            'link_embed': ep.linkEmbed,
            'server_index': serverIndex,
            'episode_index': episodeIndex,
          };
        });
      })
          .expand((i) => i)
          .toList() ??
          [];

      // Tìm index của tập hiện tại trong danh sách tất cả các tập
      final currentEpisodeIndex = allEpisodes.indexWhere(
            (e) =>
        e['name'] == episode.name &&
            e['link_m3u8'] == episode.linkM3u8 &&
            e['link_embed'] == episode.linkEmbed,
      );

      if (currentEpisodeIndex == -1) {
        print('Không tìm thấy tập trong danh sách allEpisodes!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xác định tập phim')),
        );
        return;
      }

      // Ưu tiên link m3u8 để phát trong ứng dụng
      if (episode.linkM3u8.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/video_player',
          arguments: {
            'videoUrl': '', // Không dùng videoUrl trực tiếp
            'title': '${movieDetail?.movie.name} - ${episode.name}',
            'isEmbed': false,
            'm3u8Url': episode.linkM3u8, // Truyền m3u8Url riêng
            'episodes': allEpisodes,
            'currentEpisodeIndex': currentEpisodeIndex,
          },
        );
      }
      // Nếu không có m3u8, dùng embed (không khuyến khích)
      else if (episode.linkEmbed.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phim này chỉ có link nhúng, chất lượng có thể không tốt'),
          ),
        );
        Navigator.pushNamed(
          context,
          '/video_player',
          arguments: {
            'videoUrl': episode.linkEmbed,
            'title': '${movieDetail?.movie.name} - ${episode.name}',
            'isEmbed': true,
            'episodes': allEpisodes,
            'currentEpisodeIndex': currentEpisodeIndex,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có link phát cho tập phim này')),
        );
      }
    } catch (e) {
      print('Lỗi khi mở video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở video: $e')),
      );
    }
  }

  void _handleWatchMovie() {
    if (movieDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin phim')),
      );
      return;
    }

    if (movieDetail!.hasEpisodes) {
      try {
        // Kiểm tra server và tập phim hợp lệ
        if (_selectedServerIndex >= movieDetail!.episodes.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server không hợp lệ')),
          );
          return;
        }

        final server = movieDetail!.episodes[_selectedServerIndex];
        if (server.serverData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server này không có tập phim nào')),
          );
          return;
        }

        final episodeIndex = _selectedEpisodeIndex < server.serverData.length
            ? _selectedEpisodeIndex
            : 0;
        final episode = server.serverData[episodeIndex];

        // Phát tập phim đã chọn
        _playEpisode(episode);
      } catch (e) {
        print('Error handling episodes: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở phim: $e')),
        );
      }
    } else {
      // Trường hợp không có tập phim (phim lẻ)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chức năng xem phim lẻ sẽ được cập nhật sau')),
      );
    }
  }

  List<Widget> _buildCountryChips(List<Country> countries) {
    return List<Widget>.from(
      countries.map(
            (country) => Chip(
          label: Text(
            country.name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGenreChips() {
    if (movieDetail != null && movieDetail!.hasGenres) {
      return List<Widget>.from(
        movieDetail!.movie.category.map(
              (genre) => Chip(
            label: Text(
              genre.name,
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
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        memCacheWidth: width.isFinite ? width.toInt() * 2 : null,
        memCacheHeight: height.isFinite ? height.toInt() * 2 : null,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Không thể tải hình ảnh',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

  String _formatApiDate(String apiDate) {
    try {
      final DateTime dateTime = DateTime.parse(apiDate);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years năm trước';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months tháng trước';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      // Fallback để hiển thị ngày ban đầu nếu không thể parse
      return apiDate;
    }
  }

  // Method to build a better formatted cast and crew section
  Widget _buildCastAndCrew() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diễn viên & Đạo diễn',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Directors
          if (movieDetail!.hasDirectors) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.movie_creation,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đạo diễn',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movieDetail!.movie.director.map((dir) {
                          return Chip(
                            label: Text(
                              dir,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.deepOrange.withOpacity(0.7),
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Actors
          if (movieDetail!.hasActors) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.lightBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diễn viên',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movieDetail!.movie.actor.map((actor) {
                          return Chip(
                            label: Text(
                              actor,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.blueGrey.withOpacity(0.7),
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}