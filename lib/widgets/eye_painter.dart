import 'package:flutter/material.dart';

class EyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Vẽ mắt trái
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.3, size.height * 0.6),
      paint,
    );
    // Vẽ mắt phải
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.2, size.width * 0.3, size.height * 0.6),
      paint,
    );

    // Vẽ các đường zigzag xung quanh (hiệu ứng rung)
    var zigzagPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Zigzag bên trái
    var pathLeft = Path();
    pathLeft.moveTo(size.width * 0.05, size.height * 0.3);
    pathLeft.lineTo(size.width * 0.1, size.height * 0.4);
    pathLeft.lineTo(size.width * 0.05, size.height * 0.5);
    canvas.drawPath(pathLeft, zigzagPaint);

    // Zigzag bên phải
    var pathRight = Path();
    pathRight.moveTo(size.width * 0.95, size.height * 0.3);
    pathRight.lineTo(size.width * 0.9, size.height * 0.4);
    pathRight.lineTo(size.width * 0.95, size.height * 0.5);
    canvas.drawPath(pathRight, zigzagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}