import 'package:flutter/material.dart';
import 'package:movieom_app/services/main_screen.dart';
import 'package:movieom_app/views/forgot_password.dart';
import 'package:movieom_app/views/main_login_screen.dart';
import 'package:movieom_app/views/splash_screen.dart';
import 'package:movieom_app/views/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/mainscreen': (context) => const MainScreen(),
  '/main': (context) => const MainLoginScreen(),
  '/splash': (context) => const SplashScreen(),
  '/forgot_password': (context) => const ForgotPassword(),
  '/home': (context) => const HomeScreen(),
};

// onGenerateRoute tuy chinh hieu ung chuyen trang
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