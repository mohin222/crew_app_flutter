import 'package:flutter/material.dart';

/// Exact plane/send icon traced from Figma SVG export.
/// Original viewBox: 25 x 21.
class PlaneIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const PlaneIcon({
    super.key,
    this.width = 25,
    this.height = 21,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _PlaneIconPainter(color: color),
    );
  }
}

class _PlaneIconPainter extends CustomPainter {
  final Color color;

  _PlaneIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Original artwork is 25 x 21 — scale to whatever size is requested.
    final scaleX = size.width / 25;
    final scaleY = size.height / 21;

    final path = Path();

    // --- First subpath: the trail line under the plane ---
    path.moveTo(22.9769, 18.5738);
    path.lineTo(1.73767, 18.5738);
    path.cubicTo(1.05052, 18.5738, 0.48831, 19.1197, 0.48831, 19.7869);
    path.cubicTo(0.48831, 20.4541, 1.05052, 21, 1.73767, 21);
    path.lineTo(22.9769, 21);
    path.cubicTo(23.664, 21, 24.2262, 20.4541, 24.2262, 19.7869);
    path.cubicTo(24.2262, 19.1197, 23.664, 18.5738, 22.9769, 18.5738);
    path.close();

    // --- Second subpath: the plane body ---
    path.moveTo(24.9384, 7.2189);
    path.cubicTo(24.6635, 6.2484, 23.639, 5.67824, 22.6395, 5.93299);
    path.lineTo(16.0054, 7.65563);
    path.lineTo(7.93452, 0.352618);
    path.cubicTo(7.76754, 0.198937, 7.5622, 0.0901474, 7.33875, 0.0369669);
    path.cubicTo(7.11529, -0.0162137, 6.88142, -0.0119501, 6.66017, 0.0493373);
    path.cubicTo(5.8106, 0.279831, 5.41081, 1.22607, 5.84808, 1.96607);
    path.lineTo(10.1459, 9.1963);
    path.lineTo(3.93656, 10.8098);
    path.lineTo(1.97505, 9.30548);
    path.cubicTo(1.66271, 9.07498, 1.26292, 8.99007, 0.875613, 9.08712);
    path.lineTo(0.463322, 9.1963);
    path.cubicTo(0.0635258, 9.29335, -0.123879, 9.7422, 0.0885131, 10.0819);
    path.lineTo(2.43732, 14.0245);
    path.cubicTo(2.72467, 14.4977, 3.29938, 14.7281, 3.83661, 14.5947);
    path.lineTo(23.6016, 9.45105);
    path.cubicTo(24.601, 9.18417, 25.2007, 8.1894, 24.9384, 7.2189);
    path.close();

    final matrix = Matrix4.identity()..scale(scaleX, scaleY);
    final scaledPath = path.transform(matrix.storage);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PlaneIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}