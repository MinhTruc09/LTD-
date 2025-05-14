// lib/views/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/Entity/movie_detail_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';
import 'package:movieom_app/services/favorite_movie_service.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/widgets/skeleton_widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isLoading = true;
  MovieModel? movie;
  MovieDetailModel? movieDetail;
  String? errorMessage;
  final MovieApiService _apiService = MovieApiService();
  final AuthController _authController = AuthController();
  late Favoritemovieservice _favoriteService;
  bool _isFavorite = false;
  bool _isCheckingFavorite = false;
  String _userId = 'guest';

  @override
  void initState() {
    super.initState();
    _initUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieDetails();
    });
  }

  Future<void> _initUser() async {
    try {
      final userId = await _authController.getCurrentUserId() ?? 'guest';
      setState(() {
        _userId = userId;
        _favoriteService = Favoritemovieservice(userId);
      });
    } catch (e) {
      print('Error initializing user: $e');
      setState(() {
        _userId = 'guest';
        _favoriteService = Favoritemovieservice('guest');
      });
    }
  }

  Future<void> _loadMovieDetails() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    MovieModel? movieArg;
    bool? initialFavoriteState;
    bool fromFavoriteScreen = false;

    if (args is Map) {
      movieArg = args['movie'] as MovieModel?;
      initialFavoriteState = args['isFavorite'] as bool?;
      fromFavoriteScreen = args['fromHomeScreen'] as bool? ?? false;

      if (initialFavoriteState == true) {
        setState(() {
          _isFavorite = true;
        });
        print('Đã nhận trạng thái yêu thích từ màn hình trước: $_isFavorite');
      }
    } else if (args is MovieModel) {
      movieArg = args;
    }

    if (movieArg != null) {
      if (!mounted) return;
      setState(() {
        movie = movieArg;
        isLoading = true;
      });

      try {
        if (!fromFavoriteScreen) {
          await _checkFavoriteStatus(movieArg.id);
        }

        String movieSlug = '';
        if (movie!.extraInfo != null && movie!.extraInfo!.containsKey('slug')) {
          movieSlug = movie!.extraInfo!['slug'];
        } else if (movie!.id.isNotEmpty) {
          movieSlug = movie!.id;
        }

        print('Đang tải chi tiết phim với slug/id: $movieSlug');
        final movieDetailResult = await _apiService.getMovieDetailV3(
          movieSlug,
          fallbackModel: movie,
        );

        if (movieDetailResult != null) {
          if (!mounted) return;
          setState(() {
            movieDetail = movieDetailResult;
            isLoading = false;
          });
          print('Loaded movie detail: Title: ${movieDetail?.movie.name}');
        } else {
          throw Exception('Failed to load movie details');
        }
      } catch (e) {
        print('Error loading movie details: $e');
        if (!mounted) return;
        setState(() {
          errorMessage = 'Không thể tải thông tin phim: ${e.toString()}';
          isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Invalid movie data';
        isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus(String movieId) async {
    if (_userId == 'guest') return;

    setState(() {
      _isCheckingFavorite = true;
    });

    try {
      print('Đang kiểm tra trạng thái yêu thích cho phim với ID: $movieId');
      bool isFavorite = await _favoriteService.isMovieFavorite(movieId);

      if (!isFavorite &&
          movie?.extraInfo != null &&
          movie!.extraInfo!.containsKey('slug')) {
        final slug = movie!.extraInfo!['slug'];
        if (slug != null && slug.isNotEmpty && slug != movieId) {
          print('Không tìm thấy theo ID, kiểm tra theo slug: $slug');
          final isFavoriteBySlug = await _favoriteService.isMovieFavorite(slug);
          if (isFavoriteBySlug) isFavorite = true;
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isCheckingFavorite = false;
        });
        print('Kết quả cuối cùng kiểm tra yêu thích: $_isFavorite');
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == 'guest') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này')),
      );
      return;
    }

    if (movie == null) return;

    setState(() {
      _isCheckingFavorite = true;
    });

    try {
      print('Thông tin phim: ID=${movie!.id}, Title=${movie!.title}');
      if (_isFavorite) {
        await _favoriteService.removeFavorite(movie!);
        if (mounted) {
          setState(() {
            _isFavorite = false;
            _isCheckingFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Đã xóa "${movie!.title}" khỏi danh sách yêu thích'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Hoàn tác',
                textColor: Colors.white,
                onPressed: () => _toggleFavorite(),
              ),
            ),
          );
        }
      } else {
        await _favoriteService.addFavorite(movie!);
        if (mounted) {
          setState(() {
            _isFavorite = true;
            _isCheckingFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Đã thêm "${movie!.title}" vào danh sách yêu thích'),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      if (mounted) {
        setState(() {
          _isCheckingFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, _isFavorite); // Truyền ngược trạng thái khi quay lại
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            movieDetail?.movie.name ?? 'Chi tiết phim',
            style: GoogleFonts.aBeeZee(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, _isFavorite); // Truyền ngược trạng thái
            },
          ),
        ),
        body: isLoading
            ? SkeletonWidgets.movieDetailSkeleton()
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.aBeeZee(color: Colors.white),
                    ),
                  )
                : _buildMovieDetails(),
        bottomNavigationBar:
            isLoading || errorMessage != null ? null : _buildBottomActionBar(),
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
          _buildHeroImage(posterUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 16),
                _buildKeyInfoBadges(),
                const SizedBox(height: 24),
                _buildContentSection(),
                const SizedBox(height: 24),
                _buildTechnicalDetails(),
                const SizedBox(height: 24),
                if (movieDetail!.hasEpisodes) _buildEpisodeSelector(),
                if (movieDetail!.hasActors || movieDetail!.hasDirectors)
                  _buildCastAndCrew(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetail!.movie.name,
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (movieDetail!.movie.originName.isNotEmpty)
          Text(
            movieDetail!.movie.originName,
            style: GoogleFonts.aBeeZee(
              color: Colors.grey[400],
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildKeyInfoBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoBadge(
          movieDetail!.movie.quality,
          Icons.high_quality,
          Colors.green,
        ),
        _buildInfoBadge(
          movieDetail!.movie.lang,
          Icons.language,
          Color(0xFF3F54D1),
        ),
        if (movieDetail!.movie.time.isNotEmpty)
          _buildInfoBadge(
            movieDetail!.movie.time,
            Icons.timer,
            Colors.purple,
          ),
        if (movieDetail!.movie.year != 0)
          _buildInfoBadge(
            movieDetail!.movie.year.toString(),
            Icons.calendar_today,
            Colors.amber,
          ),
        _buildInfoBadge(
          movieDetail!.displayStatus,
          Icons.info_outline,
          Colors.teal,
        ),
        _buildInfoBadge(
          movieDetail!.displayType,
          Icons.movie_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nội dung phim',
          style: GoogleFonts.aBeeZee(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movieDetail!.movie.content.isNotEmpty
              ? movieDetail!.movie.content
              : 'Không có mô tả cho phim này.',
          style: GoogleFonts.aBeeZee(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetails() {
    final movie = movieDetail!.movie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin kỹ thuật',
          style: GoogleFonts.aBeeZee(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (movie.category.isNotEmpty)
          _buildDetailRow(
              'Thể loại:', movie.category.map((c) => c.name).join(', ')),
        if (movie.time.isNotEmpty) _buildDetailRow('Thời lượng:', movie.time),
        if (movie.year > 0)
          _buildDetailRow('Năm phát hành:', movie.year.toString()),
        _buildDetailRow('Ngôn ngữ:', movie.lang),
        if (movie.quality.isNotEmpty)
          _buildDetailRow('Chất lượng:', movie.quality),
        if (movie.productionCompanies != null &&
            movie.productionCompanies!.isNotEmpty)
          _buildDetailRow(
              'Công ty sản xuất:', movie.productionCompanies!.join(', ')),
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
              style: GoogleFonts.aBeeZee(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.aBeeZee(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF3F54D1).withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách tập phim',
            style: GoogleFonts.aBeeZee(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
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
                        setState(() {
                          _selectedServerIndex = index;
                          _selectedEpisodeIndex = 0;
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
          if (movieDetail!.episodes.isNotEmpty) _buildEpisodeGrid(),
        ],
      ),
    );
  }

  int _selectedServerIndex = 0;
  int _selectedEpisodeIndex = 0;

  Widget _buildEpisodeGrid() {
    if (_selectedServerIndex >= movieDetail!.episodes.length) {
      return Center(
        child: Text(
          'Không có tập phim',
          style: GoogleFonts.aBeeZee(color: Colors.white),
        ),
      );
    }

    final episodes = movieDetail!.episodes[_selectedServerIndex].serverData;

    if (episodes.isEmpty) {
      return Center(
        child: Text(
          'Không có tập phim',
          style: GoogleFonts.aBeeZee(color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng số: ${episodes.length} tập${episodes.length > 0 ? " (Chọn tập ${_selectedEpisodeIndex + 1} - ${episodes[_selectedEpisodeIndex].name})" : ""}',
          style: GoogleFonts.aBeeZee(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Server: ${movieDetail!.episodes[_selectedServerIndex].serverName}',
          style: GoogleFonts.aBeeZee(
            color: Colors.orange,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
                    style: GoogleFonts.aBeeZee(
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

  void _playEpisode(EpisodeData episode) {
    print('Đang xử lý episode: ${episode.name}');
    print('Link M3U8: ${episode.linkM3u8}');
    print('Link Embed: ${episode.linkEmbed}');

    try {
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

      if (episode.linkM3u8.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/video_player',
          arguments: {
            'videoUrl': '',
            'title': '${movieDetail?.movie.name} - ${episode.name}',
            'isEmbed': false,
            'm3u8Url': episode.linkM3u8,
            'episodes': allEpisodes,
            'currentEpisodeIndex': currentEpisodeIndex,
          },
        );
      } else if (episode.linkEmbed.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Phim này chỉ có link nhúng, chất lượng có thể không tốt'),
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
        _playEpisode(episode);
      } catch (e) {
        print('Error handling episodes: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở phim: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Chức năng xem phim lẻ sẽ được cập nhật sau')),
      );
    }
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
            style: GoogleFonts.aBeeZee(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
                style: GoogleFonts.aBeeZee(
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
            style: GoogleFonts.aBeeZee(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
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
                        style: GoogleFonts.aBeeZee(
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
                              style: GoogleFonts.aBeeZee(
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
                        style: GoogleFonts.aBeeZee(
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
                              style: GoogleFonts.aBeeZee(
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

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _handleWatchMovie,
            child: Text(
              'Xem phim',
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _toggleFavorite,
            child: Text(
              _isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
