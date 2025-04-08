import 'package:flutter/material.dart';

class MovieomLogo extends StatelessWidget {
  const MovieomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text('MOVIEOM',
          style: TextStyle(
            fontFamily: 'RubikDoodleShadow',
            fontSize: 60,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = Colors.white,
          ),
        ),

        Transform.translate(
          offset: const Offset(3, 10),
          child: Text('MOVIEOM',
            style: TextStyle(
              fontFamily: 'RubikMarkerHatch',
              fontSize: 60,
              color: Color(0xFF3F54D1),
            ),
          ),
        )
      ],
    );
  }
}
