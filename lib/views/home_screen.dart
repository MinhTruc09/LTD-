import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/gradient_button.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';
import 'package:movieom_app/controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = AuthController();
  late User user;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    user = _authController.getCurrentUser()!;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      gradientEnd: Alignment.bottomRight,
      colors: const [Color(0xFF3F54D1), Colors.black],
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: const MovieomLogo(),
              ),
              const SizedBox(height: 20),
              // Welcome Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    "Signed in successfully as: ${user.email}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.aBeeZee(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Sign Out Button
              ScaleTransition(
                scale: _scaleAnimation,
                child: GradientButton(
                  text: "Sign Out",
                  onTap: () async {
                    await _authController.signOut();
                    // Điều hướng về màn hình đăng nhập
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/main', (route) => false);
                  },
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
