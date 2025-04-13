import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Alignment? gradientBegin; // Cho animation trong SignInScreen
  final Alignment gradientEnd;
  final List<Color> colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradientBegin,
    required this.gradientEnd,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: gradientBegin ?? Alignment.topLeft, // Mặc định nếu không có animation
          end: gradientEnd,
          colors: colors,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}