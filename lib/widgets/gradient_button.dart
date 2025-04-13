import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Color(0xFF3F54D1)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 15,
                offset: Offset(5, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}