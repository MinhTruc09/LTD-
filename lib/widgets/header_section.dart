import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderSection extends StatelessWidget {
  final Widget? icon; // Hỗ trợ cả Icon và Image.asset
  final String title;
  final String subtitle;

  const HeaderSection({
    super.key,
    this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(height: 20),
        ],
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.aBeeZee(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.aBeeZee(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}