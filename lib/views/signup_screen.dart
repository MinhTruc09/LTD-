import 'package:cloud_firestore/cloud_firestore.dart';
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

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _gradientAnimation;
  bool _isLoading = false;
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();

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

  Future signUp() async {
    if (!passwordConfirmed()) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlertDialog(
            title: "Error",
            content: "Passwords do not match",
            actionText: "Try again!",
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authController.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await _userController.addUserDetails(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        int.parse(_ageController.text.trim()),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: "Success",
            content: "Account created successfully! Please sign in.",
            actionText: "Sure!",
            onActionPressed: widget.showLoginPage, // Gọi callback
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: "Error",
            content: e.message ?? "An error occurred",
            actionText: "Oke",
          );
        },
      );
    } on FormatException {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return const CustomAlertDialog(
            title: "Error",
            content: "Please enter a valid age",
            actionText: "Try again!",
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

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: HeaderSection(
                        icon: Image.asset('assets/images/userlogo.png',
                            height: 100),
                        title: 'Create account to watch',
                        subtitle: 'Sign up',
                      ),
                    ),

                    // Input Fields Container
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 15,
                                offset: Offset(5, 5),
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
                                    return 'Please enter your email';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: "Password...",
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _confirmPasswordController,
                                hintText: "Confirm password...",
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter again your password';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _firstNameController,
                                hintText: "First name...",
                                icon: Icons.person,
                                obscureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _lastNameController,
                                hintText: "Last name...",
                                icon: Icons.person,
                                obscureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              _buildDivider(),
                              CustomTextField(
                                controller: _ageController,
                                hintText: "Age...",
                                icon: Icons.calendar_today,
                                obscureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'How old are you?';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sign Up Button
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : GradientButton(
                              text: "Sign Up",
                              onTap: signUp,
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Sign In Link
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                widget.showLoginPage, // Gọi callback trực tiếp
                            child: Text(
                              "Sign in",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF3F54D1),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDivider() {
    return const Divider(
      height: 2,
      color: Colors.white,
    );
  }
}
