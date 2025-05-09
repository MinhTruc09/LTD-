import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/services/auth_model.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/gradient_button.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientBackground(
        gradientEnd: Alignment.bottomRight,
        colors: const [Colors.black, Colors.black, Color(0xFF3F54D1)],
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // Logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const MovieomLogo(),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          textAlign: TextAlign.center,
                          "Xin chào bạn, hãy chọn phương thức đăng nhập",style:GoogleFonts.aBeeZee(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),)
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Register Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: GradientButton(
                          text: "Đăng nhập tài khoản",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthModel(),
                              ),
                            );
                          },
                          fontSize: 19,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Facebook Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: GradientButton(
                          text: "Đăng nhập Facebook",
                          onTap: () {
                            // TODO: Facebook login
                          },
                          fontSize: 19,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Text Link to Login
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthModel(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Chưa có tài khoản? ",style: GoogleFonts.aBeeZee(fontSize: 19,color: Colors.white,fontWeight: FontWeight.bold),),
                            Text(
                              "Đăng ký",
                              style: GoogleFonts.aBeeZee(
                                fontSize: 19,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}