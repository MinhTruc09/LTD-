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
    tween = Tween<double>(begin: 0, end: 359);
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
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: widget.fontSize,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.text,
                          style: GoogleFonts.poppins(
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

  List<Color> _generateGradientColors(double offset) {
    List<Color> colors = [];
    const int divisions = 10;
    for (int i = 0; i < divisions; i++) {
      double hue = (360 / divisions) * i;
      hue += offset;
      if (hue > 360) {
        hue -= 360;
      }
      final Color color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
      colors.add(color);
    }
    colors.add(colors[0]);
    return colors;
  }

  List<double> _generateGradientStops() {
    const int divisions = 10;
    List<double> stops = [];
    for (int i = 0; i <= divisions; i++) {
      stops.add(i / divisions);
    }
    return stops;
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