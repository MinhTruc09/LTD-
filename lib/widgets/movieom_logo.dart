import 'package:flutter/material.dart';

class MovieomLogo extends StatelessWidget {
  final double fontSize;

  const MovieomLogo({
    super.key,
    this.fontSize = 30, // Reduced from 60 to 30 for better AppBar fit
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'MOVIEOM',
          style: TextStyle(
            fontFamily: 'RubikDoodleShadow',
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = Colors.white,
          ),
        ),
        Transform.translate(
          offset: Offset(1.5, 5), // Reduced to match new size
          child: Text(
            'MOVIEOM',
            style: TextStyle(
              fontFamily: 'RubikMarkerHatch',
              fontSize: fontSize,
              color: Color(0xFF3F54D1),
            ),
          ),
        )
      ],
    );
  }
}
