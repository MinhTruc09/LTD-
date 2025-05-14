import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _initialized = false;

  // Danh sách các tập phim
  List<Map<String, String>> _episodes = [];
  // Tập hiện tại
  int _currentEpisodeIndex = 0;

  // Thông tin để lưu vị trí xem
  Duration? _resumePosition;

  @override
  void initState() {
    super.initState();
    // Không gọi _processVideoData ở đây
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Chỉ xử lý một lần sau khi widget được gắn vào cây
    if (!_initialized) {
      _initialized = true;
      // Gọi _processVideoData trực tiếp ở đây, không cần addPostFrameCallback
      _processVideoData();
    }
  }

  void _processVideoData() {
    // Xử lý URL từ đầu vào
    String url = widget.m3u8Url.isNotEmpty ? widget.m3u8Url : widget.videoUrl;

    // Lấy thông tin từ arguments nếu có
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      // Lấy danh sách tập phim nếu có
      if (args.containsKey('episodes') && args['episodes'] is List) {
        final episodesList = args['episodes'] as List;
        for (var ep in episodesList) {
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

        // Thiết lập tập hiện tại từ arguments nếu có
        if (args.containsKey('currentEpisodeIndex') &&
            args['currentEpisodeIndex'] is int &&
            _episodes.isNotEmpty) {
          final index = args['currentEpisodeIndex'] as int;
          if (index >= 0 && index < _episodes.length) {
            _currentEpisodeIndex = index;
            print('Sử dụng tập phim index: $_currentEpisodeIndex');
          }
        }
      }

      // Ưu tiên sử dụng m3u8Url nếu được truyền vào
      if (args.containsKey('m3u8Url') &&
          args['m3u8Url'] != null &&
          args['m3u8Url'].toString().isNotEmpty) {
        url = args['m3u8Url'].toString();
        print('Sử dụng m3u8Url từ arguments: $url');
      }
    } else {
      // Nếu không có arguments, sử dụng thông tin từ widget props
      if (widget.episodes.isNotEmpty) {
        for (var ep in widget.episodes) {
          if (ep.containsKey('link_m3u8') &&
              ep.containsKey('name')) {
            _episodes.add({
              'url': ep['link_m3u8'].toString(),
              'name': ep['name'].toString(),
            });
          }
        }
        print('Đã tải ${_episodes.length} tập phim từ widget props');

        // Thiết lập tập hiện tại
        if (widget.currentEpisodeIndex >= 0 &&
            widget.currentEpisodeIndex < _episodes.length) {
          _currentEpisodeIndex = widget.currentEpisodeIndex;
          print('Sử dụng tập phim index từ props: $_currentEpisodeIndex');
        }
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

    // Loại bỏ khoảng trắng đầu cuối
    String cleanUrl = url.trim();

    // Thêm schema nếu không có
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    try {
      Uri uri = Uri.parse(cleanUrl);
      // Đảm bảo host không trống
      if (uri.host.isEmpty) {
        print('Host trống trong URL: $cleanUrl');
        return '';
      }
      // Kiểm tra xem đường dẫn có phải .m3u8 hay không
      if (uri.path.toLowerCase().endsWith('.m3u8')) {
        print('Đây là URL HLS (m3u8): $cleanUrl');
      }
      return cleanUrl;
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
      // Thêm các headers phù hợp cho cả HTTP và HLS
      final Map<String, String> headers = {
        'User-Agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
            : 'Mozilla/5.0 (Android 10; Mobile; rv:88.0) Gecko/88.0 Firefox/88.0',
        'Referer': 'https://phimapi.com/',
        'Origin': 'https://phimapi.com',
        'Connection': 'keep-alive',
        'Accept': '*/*',
      };

      // Giải phóng controllers cũ nếu có
      _videoPlayerController?.dispose();
      _chewieController?.dispose();

      // In URL để debug
      print('Đang cố gắng phát video từ URL: $url');

      // Khởi tạo VideoPlayerController mới
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false, // Thêm tùy chọn này
        ),
      );

      // Đăng ký listener để theo dõi lỗi
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.isPlaying == false &&
            _videoPlayerController!.value.position > Duration.zero) {
          _saveResumePosition();
        }
        if (_videoPlayerController!.value.hasError) {
          print(
              'Lỗi video player: ${_videoPlayerController!.value.errorDescription}');
          setState(() {
            _hasError = true;
            _errorMessage =
                'Lỗi phát video: ${_videoPlayerController!.value.errorDescription ?? "Không thể phát nội dung này"}';
            _isLoading = false;
          });
        }
      });

      // Khởi tạo video player với timeout
      try {
        await _videoPlayerController!.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Video khởi tạo quá lâu');
          },
        );
        // Sau khi khởi tạo, thử load resume position
        await _loadResumePosition();
        if (_resumePosition != null &&
            _resumePosition! < _videoPlayerController!.value.duration) {
          await _videoPlayerController!.seekTo(_resumePosition!);
        }
      } catch (timeoutError) {
        print('Timeout khởi tạo video: $timeoutError');
        setState(() {
          _hasError = true;
          _errorMessage =
              'Thời gian tải video quá lâu. Vui lòng thử lại hoặc kiểm tra kết nối mạng.';
          _isLoading = false;
        });
        return;
      }

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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _initializePlayer(_currentUrl),
                  child: const Text('Thử lại'),
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

  // Đổi episode bằng URL thay vì index, cho phép xác định lại máy chủ
  void _changeEpisodeByUrl(String url, String name) {
    _saveResumePosition(); // Lưu vị trí tập cũ
    if (url.isNotEmpty) {
      setState(() {
        _currentUrl = _validateAndProcessUrl(url);
        _resumePosition = null; // Reset resume cho tập mới
        // Reset trạng thái
        _hasError = false;
        _errorMessage = '';
      });
      print('Đổi sang tập: $name với URL: $_currentUrl');
      _initializePlayer(_currentUrl);
    }
  }

  // Thử phát từ server thay thế nếu có
  void _tryAlternativeServer() {
    // Chỉ thực hiện nếu có episodes
    if (_episodes.isNotEmpty) {
      // Tìm URL thay thế trong episodes hiện tại
      int currentIndex = _currentEpisodeIndex;

      // Thử tìm URL khác với định dạng khác
      for (int i = 0; i < _episodes.length; i++) {
        if (i != currentIndex &&
            _episodes[i]['url'] != null &&
            _episodes[i]['url']!.isNotEmpty) {
          _changeEpisodeByUrl(
              _episodes[i]['url']!, _episodes[i]['name'] ?? 'Tập khác');

          setState(() {
            _currentEpisodeIndex = i;
          });

          print('Đã thử máy chủ thay thế: ${_episodes[i]['name']}');
          return;
        }
      }

      // Nếu không tìm thấy, thông báo cho người dùng
      setState(() {
        _errorMessage = 'Không tìm thấy máy chủ thay thế để phát video này.';
      });
    }
  }

  // Tạo key duy nhất cho mỗi phim/tập
  String _buildResumeKey() {
    // Ưu tiên slug, nếu không có thì dùng id hoặc url
    String movieId = '';
    if (widget.title.isNotEmpty) {
      movieId = widget.title;
    } else if (_currentUrl.isNotEmpty) {
      movieId = _currentUrl;
    }
    return 'resume_${movieId}_ep_$_currentEpisodeIndex';
  }

  // Lưu vị trí xem
  Future<void> _saveResumePosition() async {
    if (_videoPlayerController == null) return;
    final prefs = await SharedPreferences.getInstance();
    final pos = _videoPlayerController!.value.position.inSeconds;
    final key = _buildResumeKey();
    await prefs.setInt(key, pos);
  }

  // Đọc vị trí xem
  Future<void> _loadResumePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _buildResumeKey();
    final pos = prefs.getInt(key);
    if (pos != null && pos > 0) {
      _resumePosition = Duration(seconds: pos);
    } else {
      _resumePosition = null;
    }
  }

  @override
  void dispose() {
    _saveResumePosition(); // Lưu vị trí khi thoát
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
    // Phân tích tiêu đề thành tên phim và tập
    String movieTitle = 'Đang xem';
    String episodeTitle = '';

    if (widget.title.contains('-')) {
      final parts = widget.title.split('-');
      if (parts.length >= 2) {
        movieTitle = parts[0].trim();
        episodeTitle = parts[1].trim();
      } else {
        movieTitle = widget.title;
      }
    } else {
      movieTitle = widget.title;
    }

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
            fontSize: 16, // Giảm kích thước để tránh tràn
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
          // Phần trình phát video
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

              // Thanh nhỏ hiển thị tập đang xem (luôn hiển thị)
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
                            episodeTitle.isNotEmpty
                                ? 'Đang xem: $episodeTitle'
                                : 'Đang xem: ${_episodes[_currentEpisodeIndex]['name']}',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            if (_episodes.length > 1)
              ElevatedButton(
                onPressed: _tryAlternativeServer,
                child: const Text('Thử máy chủ khác'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
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

    // Phân tích tiêu đề giống như trong build
    String localEpisodeTitle = '';
    if (widget.title.contains('-')) {
      final parts = widget.title.split('-');
      if (parts.length >= 2) {
        localEpisodeTitle = parts[1].trim();
      }
    }

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
                    localEpisodeTitle.isNotEmpty
                        ? 'Đang xem: $localEpisodeTitle'
                        : 'Đang xem: ${_episodes[_currentEpisodeIndex]['name']}',
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
                            _changeEpisodeByUrl(_episodes[index]['url']!,
                                _episodes[index]['name'] ?? 'Tập ${index + 1}');
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
