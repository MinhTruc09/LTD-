import 'package:flutter/material.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/services/main_screen.dart';
import 'package:movieom_app/views/main_login_screen.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();

    // Khởi tạo AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Kiểm tra trạng thái đăng nhập và chuyển hướng tương ứng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // Phương thức kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    try {
      // Chờ một chút để hiệu ứng splash screen hiển thị
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Kiểm tra xem người dùng đã đăng nhập chưa
      final isLoggedIn = await _authController.isUserLoggedIn();

      if (isLoggedIn) {
        // Nếu đã đăng nhập, chuyển đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Nếu chưa đăng nhập, chuyển đến màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLoginScreen()),
        );
      }
    } catch (e) {
      // Xử lý lỗi - mặc định chuyển đến màn hình đăng nhập
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        gradientEnd: Alignment.bottomRight,
        colors: const [Color(0xFF3F54D1), Colors.black],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const MovieomLogo(
                  fontSize: 60,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
