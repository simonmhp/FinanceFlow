import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm; // Added a prefix
import '../common/color_extension.dart';

class CustomArcPainter extends CustomPainter {
  final double start;
  final double end; // The end angle for the arc
  final double width;
  final double blurWidth;

  CustomArcPainter({
    this.start = 0,
    this.end = 270, // This will correspond to the arc's angle
    this.width = 15,
    this.blurWidth = 6,
  });

  // Method to determine the gradient color based on the arc percentage
  LinearGradient getGradientColor() {
    // Convert 'end' (which is an angle) to a percentage
    double percentage = (end / 270) * 100;

    // Apply color based on the percentage value
    if (percentage <= 20) {
      return LinearGradient(
        colors: [Colors.green, Colors.green],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (percentage <= 40) {
      return LinearGradient(
        colors: [Colors.green[800]!, Colors.green[800]!], // Dark Green
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (percentage <= 60) {
      return LinearGradient(
        colors: [Colors.orange, Colors.orange],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (percentage <= 80) {
      return LinearGradient(
        colors: [Colors.red[200]!, Colors.red[200]!], // Light Red
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return LinearGradient(
        colors: [Colors.red, Colors.red],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Use the gradient color based on the arc percentage
    var gradientColor = getGradientColor();

    Paint activePaint = Paint()..shader = gradientColor.createShader(rect);
    activePaint.style = PaintingStyle.stroke;
    activePaint.strokeWidth = width;
    activePaint.strokeCap = StrokeCap.round;

    Paint backgroundPaint = Paint();
    backgroundPaint.color = TColor.gray60.withOpacity(0.5);
    backgroundPaint.style = PaintingStyle.stroke;
    backgroundPaint.strokeWidth = width;
    backgroundPaint.strokeCap = StrokeCap.round;

    Paint shadowPaint = Paint()
      ..color = TColor.secondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    var startVal = 135.0 + start;

    // Draw the background arc (full 270 degrees)
    canvas.drawArc(rect, vm.radians(startVal), vm.radians(270), false,
        backgroundPaint); // Prefix for radians

    // Draw the shadow arc
    Path path = Path();
    path.addArc(
        rect, vm.radians(startVal), vm.radians(end)); // Prefix for radians
    canvas.drawPath(path, shadowPaint);

    // Draw the active arc
    canvas.drawArc(rect, vm.radians(startVal), vm.radians(end), false,
        activePaint); // Prefix for radians
  }

  @override
  bool shouldRepaint(CustomArcPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomArcPainter oldDelegate) => false;
}
