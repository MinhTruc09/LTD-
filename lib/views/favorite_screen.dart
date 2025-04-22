import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/Appbarfavorite.dart';
import 'package:movieom_app/widgets/AnimatedPlayButton.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/favoritemovieservice.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'dart:async';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<bool> isPlayingList;
  List<MovieModel> favoriteMovies = [];
  late Favoritemovieservice _favoriteService;
  final AuthController _authController = AuthController();
  String _currentUserId = '';
  StreamSubscription<String>? _userIdSubscription;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _userIdSubscription = _authController.userIdStream.listen((newUserId) {
      if (newUserId != _currentUserId) {
        _onAccountChanged(newUserId);
      }
    });
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
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final userId = await _authController.getCurrentUserId() ?? 'guest';
    print('UserID in FavoriteScreen: $userId');
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _favoriteService = Favoritemovieservice(userId);
    });
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoriteService.getFavorites();
      print('Favorites loaded for user $_currentUserId: $favorites');
      if (!mounted) return;
      setState(() {
        favoriteMovies = favorites;
        isPlayingList = List.generate(favoriteMovies.length, (_) => false);
      });
    } catch (e) {
      print('Error loading favorites: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
      setState(() {
        favoriteMovies = [];
        isPlayingList = [];
      });
    }
  }

  Future<void> _onAccountChanged(String newUserId) async {
    print('Changing to new UserID: $newUserId');
    final userIdToUse = newUserId.isEmpty ? 'guest' : newUserId;
    if (!mounted) return;
    setState(() {
      _currentUserId = userIdToUse;
      _favoriteService = Favoritemovieservice(userIdToUse);
    });
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const Appbarfavorite(),
          Expanded(
            child: favoriteMovies.isEmpty
                ? Center(
                    child: Text(
                      'Bạn chưa có phim yêu thích',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = favoriteMovies[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 200,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: movie.imageUrl.isNotEmpty
                                      ? Image.network(
                                          movie.imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey,
                                              child: Center(
                                                child: Text(
                                                  movie.title,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          child: Center(
                                            child: Text(
                                              movie.title,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 15),
                                AnimatedPlayButton(
                                  initialIsPlaying: isPlayingList[index],
                                  onPressed: () {
                                    setState(() {
                                      isPlayingList[index] =
                                          !isPlayingList[index];
                                    });
                                    print(isPlayingList[index]
                                        ? 'Phát ${movie.title}'
                                        : 'Tạm dừng ${movie.title}');
                                  },
                                  playIcon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  pauseIcon: const Icon(
                                    Icons.pause,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (movie.year.isNotEmpty)
                                  SizedBox(
                                    height: 15,
                                    child: Text(
                                      movie.year,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
