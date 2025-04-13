import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String actionText;
  final VoidCallback? onActionPressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onActionPressed != null) {
              onActionPressed!();
            }
          },
          child: Text(
            actionText,
            style: GoogleFonts.poppins(
              color: const Color(0xFF3F54D1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}