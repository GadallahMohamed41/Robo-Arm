import 'package:flutter/material.dart';

/// Solid-black schematic arm + faint lab grid (matches reference screenshot).
class RobotArmCanvas extends StatelessWidget {
  const RobotArmCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IndustrialArmPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _IndustrialArmPainter extends CustomPainter {
  static const _black = Color(0xFF000000);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint grid (reference: light gray on white)
    final grid = Paint()
      ..color = const Color(0xFFD9D9DD)
      ..strokeWidth = 0.6;
    for (var i = 0; i <= 10; i++) {
      final y = h * (i / 10);
      canvas.drawLine(Offset(0, y), Offset(w * 0.52, y), grid);
    }
    for (var i = 0; i <= 8; i++) {
      final x = w * (i / 14);
      canvas.drawLine(Offset(x, 0), Offset(x, h * 0.98), grid);
    }

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.775, w * 0.36, h * 0.125),
      const Radius.circular(10),
    );

    final fill = Paint()
      ..color = _black
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = _black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(baseRect, fill);

    // Turntable disc
    final turntable = Offset(w * 0.28, h * 0.775);
    canvas.drawCircle(turntable, w * 0.055, fill);
    canvas.drawCircle(turntable, w * 0.055, outline);

    final joints = <Offset>[
      Offset(w * 0.28, h * 0.715),
      Offset(w * 0.33, h * 0.575),
      Offset(w * 0.40, h * 0.435),
      Offset(w * 0.48, h * 0.305),
      Offset(w * 0.54, h * 0.195),
      Offset(w * 0.58, h * 0.085),
    ];

    final limb = Paint()
      ..color = _black
      ..strokeWidth = w * 0.048
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < joints.length - 1; i++) {
      canvas.drawLine(joints[i], joints[i + 1], limb);
    }

    for (final j in joints) {
      canvas.drawCircle(j, w * 0.026, fill);
      canvas.drawCircle(j, w * 0.026, outline);
    }

    // Simple gripper
    final g = joints.last;
    final claw = Path()
      ..moveTo(g.dx - w * 0.015, g.dy + h * 0.022)
      ..lineTo(g.dx + w * 0.04, g.dy - h * 0.018)
      ..lineTo(g.dx + w * 0.09, g.dy - h * 0.012);
    canvas.drawPath(
      claw,
      Paint()
        ..color = _black
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
