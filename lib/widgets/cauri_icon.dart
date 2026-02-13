import 'package:flutter/material.dart';

class CauriIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CauriIcon({super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF92400E));

    return CustomPaint(
      size: Size(size, size),
      painter: CauriPainter(color: iconColor),
    );
  }
}

class CauriPainter extends CustomPainter {
  final Color color;
  CauriPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // 1. Forme extérieure du cauri
    final outerPath = Path();
    outerPath.moveTo(w * 0.5, 0);
    outerPath.cubicTo(w * 0.9, 0, w, h * 0.4, w * 0.9, h * 0.85);
    outerPath.lineTo(w * 0.7, h);
    outerPath.lineTo(w * 0.3, h);
    outerPath.lineTo(w * 0.1, h * 0.85);
    outerPath.cubicTo(0, h * 0.4, w * 0.1, 0, w * 0.5, 0);
    outerPath.close();
    canvas.drawPath(outerPath, paint);

    // 2. Fente centrale avec dents (Zig-zag)
    final slotPath = Path();
    double startY = h * 0.2;
    double endY = h * 0.8;
    double midX = w * 0.5;
    double zigWidth = w * 0.08;
    int teethCount = 8;
    double step = (endY - startY) / teethCount;

    slotPath.moveTo(midX, startY);
    for (int i = 0; i <= teethCount; i++) {
      double y = startY + (i * step);
      double x = midX + (i % 2 == 0 ? zigWidth : -zigWidth);
      slotPath.lineTo(x, y);
    }
    canvas.drawPath(slotPath, paint);

    // 3. Petits cercles caractéristiques sur les bords
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    // Gauche
    canvas.drawCircle(Offset(w * 0.25, h * 0.3), size.width * 0.06, dotPaint);
    canvas.drawCircle(Offset(w * 0.2, h * 0.5), size.width * 0.07, dotPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.7), size.width * 0.06, dotPaint);

    // Droite
    canvas.drawCircle(Offset(w * 0.75, h * 0.3), size.width * 0.06, dotPaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.5), size.width * 0.07, dotPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.7), size.width * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
