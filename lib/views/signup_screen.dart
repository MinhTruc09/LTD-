import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/gradient_background.dart';
import 'package:movieom_app/widgets/gradient_button.dart';
import 'package:movieom_app/widgets/header_section.dart';
import 'package:movieom_app/widgets/custom_text_field.dart';
import 'package:movieom_app/widgets/custom_alert_dialog.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/controllers/user_controller.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignupScreen({super.key, required this.showLoginPage});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  final AuthController _authController = AuthController();
  final UserController _userController = UserController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _gradientAnimation;

  bool _isLoading = false;

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
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!passwordConfirmed()) {
      _showErrorDialog("Mật khẩu không trùng khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authController.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      final userId = userCredential.user?.uid;

      if (userId == null) {
        throw Exception('Không lấy được User ID sau đăng ký.');
      }

      await _userController.addUserDetails(
        userId: userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      );

      if (!mounted) return;
      _showSuccessDialog("Tạo tài khoản thành công! Vui lòng đăng nhập.");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.message ?? "Có lỗi xảy ra.");
    } on FormatException {
      if (!mounted) return;
      _showErrorDialog("Vui lòng nhập tuổi hợp lệ!");
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmPasswordController.text.trim();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: "Lỗi",
        content: message,
        actionText: "Thử lại!",
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: "Thành công",
        content: message,
        actionText: "Đồng ý!",
        onActionPressed: widget.showLoginPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GradientBackground(
            gradientBegin: _gradientAnimation.value,
            gradientEnd: Alignment.center,
            colors: const [Color(0xFF3F54D1), Colors.black],
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: HeaderSection(
                        title: 'Tạo tài khoản để xem phim đi',
                        subtitle: 'Đăng ký',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildForm(),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : GradientButton(
                        text: "Đăng ký",
                        onTap: signUp,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoginRedirect(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(5, 5)),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            hintText: "Email...",
            icon: Icons.email_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email!';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                return 'Email không hợp lệ!';
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
            validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mật khẩu!' : null,
          ),
          _buildDivider(),
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: "Xác nhận mật khẩu...",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) => value == null || value.isEmpty ? 'Vui lòng xác nhận mật khẩu!' : null,
          ),
          _buildDivider(),
          CustomTextField(
            controller: _firstNameController,
            hintText: "Họ...",
            icon: Icons.person,
            validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ!' : null,
          ),
          _buildDivider(),
          CustomTextField(
            controller: _lastNameController,
            hintText: "Tên...",
            icon: Icons.person,
            validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên!' : null,
          ),
          _buildDivider(),
          CustomTextField(
            controller: _ageController,
            hintText: "Tuổi...",
            icon: Icons.calendar_today,
            validator: (value) => value == null || value.isEmpty ? 'Bạn nhiêu tuổi rồi?' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Có tài khoản rồi hả? ",
          style: GoogleFonts.aBeeZee(color: Colors.white),
        ),
        GestureDetector(
          onTap: widget.showLoginPage,
          child: Text(
            "Đăng nhập",
            style: GoogleFonts.aBeeZee(
              color: const Color(0xFF3F54D1),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 3, color: Colors.white);
  }
}
