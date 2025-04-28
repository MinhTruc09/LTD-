import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/custom_text_field.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/gradient_button.dart';
import 'package:movieom_app/widgets/header_section.dart';
import 'package:movieom_app/widgets/custom_alert_dialog.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const SignInScreen({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _gradientAnimation;
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

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authController.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mainscreen',
              (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: "Lỗi đăng nhập",
            content: e.message ?? "Xin lỗi, Hiện tại không thể đăng nhập",
            actionText: "Đồng ý !",
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GradientBackground(
            gradientBegin: _gradientAnimation.value,
            gradientEnd: Alignment.center,
            colors: const [Color(0xFF3F54D1), Colors.black],
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: HeaderSection(
                          icon: Image.asset('assets/images/userlogo.png', height: 120),
                          title: "Đem lại những bộ phim chất lượng",
                          subtitle: "Vui lòng đăng nhập tài khoản",
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                hintText: "Email...",
                                icon: Icons.email_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập email của bạn';
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Vui lòng nhập email hợp lệ!';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: "Mật khẩu...",
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu của bạn!';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              "Quên mật khẩu?",
                              style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : GradientButton(
                          text: "Đăng nhập",
                          onTap: signIn,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Chưa có tài khoản? ",
                              style: GoogleFonts.aBeeZee(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: widget.showRegisterPage,
                              child: Text(
                                "Đăng ký",
                                style: GoogleFonts.aBeeZee(
                                  color: const Color(0xFF3F54D1),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 3,
      color: Colors.white,
    );
  }
}
