// lib/views/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isEmbed;
  final String m3u8Url;
  final List<Map<String, dynamic>> episodes;
  final int currentEpisodeIndex;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.isEmbed = false,
    this.m3u8Url = '',
    this.episodes = const [],
    this.currentEpisodeIndex = 0,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentUrl = '';

  // Danh sách các tập phim
  List<Map<String, String>> _episodes = [];
  // Tập hiện tại
  int _currentEpisodeIndex = 0;

  @override
  void initState() {
    super.initState();
    _processVideoData();
  }

  void _processVideoData() {
    // Xử lý URL từ đầu vào
    String url = widget.m3u8Url.isNotEmpty ? widget.m3u8Url : widget.videoUrl;

    // Chuyển đổi danh sách tập phim từ widget.episodes
    if (widget.episodes.isNotEmpty) {
      for (var ep in widget.episodes) {
        if (ep is Map &&
            ep.containsKey('link_m3u8') &&
            ep.containsKey('name')) {
          _episodes.add({
            'url': ep['link_m3u8'].toString(),
            'name': ep['name'].toString(),
          });
        }
      }
      print('Đã tải ${_episodes.length} tập phim');

      // Thiết lập tập hiện tại
      if (widget.currentEpisodeIndex >= 0 &&
          widget.currentEpisodeIndex < _episodes.length) {
        _currentEpisodeIndex = widget.currentEpisodeIndex;
        print('Sử dụng tập phim index: $_currentEpisodeIndex');
      } else {
        _currentEpisodeIndex = 0;
        print('Index không hợp lệ, sử dụng tập đầu tiên');
      }
    }

    // Xử lý URL
    if (url.isNotEmpty) {
      _currentUrl = _validateAndProcessUrl(url);
      _initializePlayer(_currentUrl);
    } else if (_episodes.isNotEmpty) {
      // Nếu không có URL trực tiếp nhưng có danh sách tập, sử dụng tập đã chọn
      _currentUrl =
          _validateAndProcessUrl(_episodes[_currentEpisodeIndex]['url'] ?? '');
      _initializePlayer(_currentUrl);
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Không tìm thấy URL video hợp lệ.';
        _isLoading = false;
      });
    }
  }

  String _validateAndProcessUrl(String url) {
    // Kiểm tra và xử lý URL để đảm bảo định dạng đúng
    if (url.isEmpty) {
      return '';
    }

    // Thêm schema nếu không có
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      Uri.parse(url); // Kiểm tra URL có thể parse được không
      return url;
    } catch (e) {
      print('URL không hợp lệ: $e');
      return '';
    }
  }

  Future<void> _initializePlayer(String url) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    if (url.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'URL video không hợp lệ hoặc trống';
      });
      return;
    }

    // Kiểm tra kết nối Internet
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('Không có kết nối Internet');
      }
    } catch (e) {
      print('Lỗi kết nối Internet: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Vui lòng kiểm tra kết nối Internet và thử lại.';
      });
      return;
    }

    try {
      // Thêm các headers phù hợp
      final Map<String, String> headers = {
        'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148',
        'Referer': 'https://phimapi.com/',
        'Origin': 'https://phimapi.com',
      };

      // Giải phóng controllers cũ nếu có
      _videoPlayerController?.dispose();
      _chewieController?.dispose();

      // Khởi tạo VideoPlayerController mới
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );

      // Đăng ký listener để theo dõi lỗi
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.hasError) {
          print(
              'Lỗi video player: ${_videoPlayerController!.value.errorDescription}');
          setState(() {
            _hasError = true;
            _errorMessage =
            'Lỗi phát video: ${_videoPlayerController!.value.errorDescription}';
            _isLoading = false;
          });
        }
      });

      // Khởi tạo video player
      await _videoPlayerController!.initialize();

      // Sau khi khởi tạo thành công, tạo ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: Colors.grey,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        autoInitialize: false, // Không cần khởi tạo lại vì đã khởi tạo ở trên
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 42),
                const SizedBox(height: 12),
                Text(
                  'Lỗi phát video: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        // Tùy chỉnh hiển thị tiêu đề
        customControls: CustomMaterialControls(movieTitle: widget.title),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khởi tạo trình phát: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Lỗi khởi tạo trình phát: $e';
        });
      }
    }
  }

  // Phương thức để chuyển tập phim
  void _changeEpisode(int index) {
    if (index >= 0 && index < _episodes.length) {
      setState(() {
        _currentEpisodeIndex = index;
      });

      String url = _validateAndProcessUrl(_episodes[index]['url'] ?? '');
      if (url.isNotEmpty) {
        _currentUrl = url;
        _initializePlayer(url);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Không có URL hợp lệ cho tập này';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Phân tích tiêu đề thành tên phim
    String movieTitle = widget.title.contains('-')
        ? widget.title.split('-')[0].trim()
        : widget.title;

    // Lấy tiêu đề tập từ _episodes nếu có
    String episodeTitle = _episodes.isNotEmpty
        ? _episodes[_currentEpisodeIndex]['name'] ?? ''
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          movieTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Nút toàn màn hình
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              if (_chewieController != null) {
                _chewieController!.toggleFullScreen();
              }
            },
            tooltip: 'Toàn màn hình',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Phần trình phát video và điều khiển tập
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : _hasError
                    ? _buildErrorWidget()
                    : _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const Center(
                  child: Text(
                    'Không thể khởi tạo trình phát',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              // Nút Tập trước và Tập sau (nếu có danh sách tập)
              if (_episodes.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentEpisodeIndex > 0
                            ? () => _changeEpisode(_currentEpisodeIndex - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentEpisodeIndex > 0
                              ? Colors.blue
                              : Colors.grey.shade700,
                        ),
                        child: const Text('Tập trước'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                        _currentEpisodeIndex < _episodes.length - 1
                            ? () => _changeEpisode(_currentEpisodeIndex + 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _currentEpisodeIndex < _episodes.length - 1
                              ? Colors.blue
                              : Colors.grey.shade700,
                        ),
                        child: const Text('Tập sau'),
                      ),
                    ],
                  ),
                ),

              // Thanh nhỏ hiển thị tập đang xem (luôn hiển thị nếu có danh sách tập)
              if (_episodes.length > 1)
                InkWell(
                  onTap: () => _toggleEpisodeSheet(),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.black87,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đang xem: $episodeTitle',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_up,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Phần danh sách tập phim có thể vuốt
          if (_episodes.length > 1) _buildDraggableEpisodeSheet(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể phát video: $_errorMessage',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializePlayer(_currentUrl),
              child: const Text('Thử lại'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  // Biến để theo dõi trạng thái hiển thị của bảng danh sách tập
  bool _showEpisodeSheet = false;

  // Phương thức để hiện/ẩn bảng danh sách tập
  void _toggleEpisodeSheet() {
    setState(() {
      _showEpisodeSheet = !_showEpisodeSheet;
    });
  }

  // Xây dựng bảng danh sách tập có thể vuốt
  Widget _buildDraggableEpisodeSheet() {
    if (!_showEpisodeSheet) return const SizedBox.shrink();

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Vuốt xuống - ẩn sheet
          _toggleEpisodeSheet();
        }
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề và nút đóng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách tập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _toggleEpisodeSheet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Đang xem: ${_episodes[_currentEpisodeIndex]['name']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danh sách tập
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.0,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _episodes.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentEpisodeIndex;
                        return ElevatedButton(
                          onPressed: () {
                            _changeEpisode(index);
                            _toggleEpisodeSheet(); // Ẩn sheet sau khi chọn
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            isSelected ? Colors.red : Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Center(
                            child: Text(
                              _episodes[index]['name'] ?? 'Tập ${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Tạo lớp kiểm soát video tùy chỉnh để loại bỏ tiêu đề "Player"
class CustomMaterialControls extends MaterialControls {
  final String movieTitle;

  const CustomMaterialControls({this.movieTitle = 'Movieom'});

  @override
  Widget buildTopBar(BuildContext context, ChewieController controller,
      Animation<double> controlsAnimation) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: AnimatedOpacity(
        opacity: controlsAnimation.value,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              // Nút quay lại
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              // Tiêu đề phim thay cho Player
              Expanded(
                child: Text(
                  movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

              // Nút toàn màn hình
              IconButton(
                onPressed: () {
                  controller.toggleFullScreen();
                },
                icon: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}