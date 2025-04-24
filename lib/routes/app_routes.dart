// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:movieom_app/services/main_screen.dart';
import 'package:movieom_app/views/forgot_password.dart';
import 'package:movieom_app/views/main_login_screen.dart';
import 'package:movieom_app/views/movie_detail_screen.dart';
import 'package:movieom_app/views/movie_home_screen.dart';
import 'package:movieom_app/views/splash_screen.dart';
import 'package:movieom_app/views/home_screen.dart';
import 'package:movieom_app/views/video_player_screen.dart';


import '../views/search_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/mainscreen': (context) => const MainScreen(),
  '/main': (context) => const MainLoginScreen(),
  '/splash': (context) => const SplashScreen(),
  '/forgot_password': (context) => const ForgotPassword(),
  '/home': (context) => const HomeScreen(),
  '/movie_home': (context) => const MovieHomeScreen(),
  '/movie_detail': (context) => const MovieDetailScreen(),
  '/video_player': (context) => const VideoPlayerScreen(
    videoUrl: '',
    title: 'Movieom Player',
  ),
  '/search': (context) => const SearchScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  Widget page;
  switch (settings.name) {
    case '/mainscreen':
      page = const MainScreen();
      break;
    case '/splash':
      page = const SplashScreen();
      break;
    case '/main':
      page = const MainLoginScreen();
      break;
    case '/forgot_password':
      page = const ForgotPassword();
      break;
    case '/home':
      page = const HomeScreen();
      break;
    case '/movie_home':
      page = const MovieHomeScreen();
      break;
    case '/movie_detail':
      page = const MovieDetailScreen();
      break;
    case '/video_player':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      page = VideoPlayerScreen(
        videoUrl: args['videoUrl'] as String? ?? '',
        title: args['title'] as String? ?? 'Movieom Player',
        isEmbed: args['isEmbed'] as bool? ?? false,
        m3u8Url: args['m3u8Url'] as String? ?? '',
        episodes: args['episodes'] as List<Map<String, dynamic>>? ?? [],
        currentEpisodeIndex: args['currentEpisodeIndex'] as int? ?? 0,
      );
      break;
    case '/search':
      page = const SearchScreen();
      break;
    default:
      page = const SplashScreen();
      break;
  }
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}