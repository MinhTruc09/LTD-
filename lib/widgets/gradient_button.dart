import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double fontSize;
  final IconData? icon;
  final Color? iconColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize = 20,
    this.icon,
    this.iconColor,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Tween<double> tween;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    tween = Tween<double>(begin: 0, end: 1);
    animation = controller.drive(tween);

    controller.forward();
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return CustomPaint(
              painter: GradientBorderPainter(
                gradientColors: _generateGradientColors(animation.value),
                gradientStops: _generateGradientStops(),
                borderRadius: 15,
                borderWidth: 4,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Center(
                  child: widget.icon != null
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor ?? Colors.white,
                        size: widget.fontSize + 4,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: GoogleFonts.aBeeZee(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.fontSize,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    widget.text,
                    style: GoogleFonts.aBeeZee(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.fontSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> _generateGradientColors(double value) {
    // Tạo gradient từ xanh sang trắng
    return [
      Color.lerp(Color(0xFF3F54D1), Colors.white, value)!,
      Color.lerp(Colors.white, Color(0xFF3F54D1), value)!,
    ];
  }

  List<double> _generateGradientStops() {
    return [0.0, 1.0];
  }
}

class GradientBorderPainter extends CustomPainter {
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final double borderRadius;
  final double borderWidth;

  GradientBorderPainter({
    required this.gradientColors,
    required this.gradientStops,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Tạo gradient cho viền
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: gradientColors,
      stops: gradientStops,
    );

    // Tạo Paint cho viền
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Vẽ viền ngoài
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}