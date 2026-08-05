import 'package:flutter/material.dart';

/// Decorative dish/bowl shape traced from Figma SVG export.
/// Original viewBox: 65 x 14.
class BowlShape extends StatelessWidget {
  final double width;
  final double height;

  const BowlShape({
    super.key,
    this.width = 65,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BowlShapePainter(),
    );
  }
}

class _BowlShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 65;
    final scaleY = size.height / 14;

    final path = Path();
    path.moveTo(64.4923, 6.61446);
    path.cubicTo(64.4923, 4.77108, 51.2522, 0, 32.3529, 0);
    path.cubicTo(13.4537, 0, 0, 4.77108, 0, 6.39759);
    path.cubicTo(0, 9, 12.3859, 13.1205, 32.3529, 13.1205);
    path.cubicTo(52.4267, 13.1205, 64.4923, 9.10843, 64.4923, 6.61446);
    path.close();

    final matrix = Matrix4.identity()..scale(scaleX, scaleY);
    final scaledPath = path.transform(matrix.storage);

    // Vertical gradient, top to bottom, matching Figma stops exactly.
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE3E3E3),
        Color(0xFFE1E1E1),
        Color(0xFFD8D8D9),
        Color(0xFFCCCCCE),
        Color(0xFFC1C2C4),
        Color(0xFFB7B8BA),
        Color(0xFFC7C8CA),
      ],
      stops: [0.0, 0.1771, 0.2808, 0.3569, 0.4148, 0.4941, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BowlShapePainter oldDelegate) => false;
}