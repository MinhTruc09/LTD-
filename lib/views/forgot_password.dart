import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieom_app/widgets/custom_text_field.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/gradient_button.dart';
import 'package:movieom_app/widgets/header_section.dart';
import 'package:movieom_app/widgets/custom_alert_dialog.dart';
import 'package:movieom_app/widgets/input_container.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';
import 'package:movieom_app/controllers/auth_controller.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  final AuthController _authController = AuthController();

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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlertDialog(
            title: "Lỗi",
            content: "Vui lòng nhập email",
            actionText: "Thử lại!",
          );
        },
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlertDialog(
            title: "Lỗi",
            content: "Vui lòng nhập email hợp lệ",
            actionText: "Thử lại!",
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authController.resetPassword(email);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlertDialog(
            title: "Thành công",
            content: "Link đổi mật khẩu đã được gửi! kiểm tra email của bạn.",
            actionText: "Đồng ý!",
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: "Lỗi",
            content: e.message ?? "Đã phát hiện lỗi",
            actionText: "Oke",
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
        ),
      ),
      body: GradientBackground(
        gradientEnd: Alignment.bottomRight,
        colors: const [
          Colors.black,
          Color(0xFF3F54D1)
        ], // Đồng bộ với SignInScreen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            FadeTransition(
              opacity: _fadeAnimation,
              child: const MovieomLogo(),
            ),

            // Header Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const Icon(Icons.key, color: Colors.white, size: 50),
                  const HeaderSection(
                    title: "Đổi mật khẩu",
                    subtitle: "Nhập email để đổi mật khẩu",
                  ),
                ],
              ),
            ),

            // Email Input Field
            FadeTransition(
              opacity: _fadeAnimation,
              child: InputContainer(
                child: CustomTextField(
                  controller: _emailController,
                  hintText: "Email...",
                  icon: Icons.email_rounded,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Reset Button with Loading Indicator
            ScaleTransition(
              scale: _scaleAnimation,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : GradientButton(
                      text: "Gửi mã",
                      onTap: passwordReset,
                      fontSize: 18,
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
