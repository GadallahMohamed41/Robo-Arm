// NEW FILE: lib/core/widgets/arm_slider.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// A futuristic slider for robotic arm joint control.
class ArmSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color color;
  final String unit;
  final IconData? icon;

  const ArmSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = -180,
    this.max = 180,
    this.color = AppColors.neonCyan,
    this.unit = '°',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: color.withValues(alpha: 0.3),
      glowColor: color.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Angle display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Custom slider track
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Active track
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.5), color],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Slider widget (invisible but functional)
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: color,
                  overlayColor: color.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}$unit',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '${max.toInt()}$unit',
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular angle indicator / gauge widget.
class AngleGauge extends StatelessWidget {
  final String label;
  final double angle;
  final double maxAngle;
  final Color color;
  final double size;

  const AngleGauge({
    super.key,
    required this.label,
    required this.angle,
    this.maxAngle = 180,
    this.color = AppColors.neonCyan,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(
              angle: angle,
              maxAngle: maxAngle,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${angle.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 11,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double angle;
  final double maxAngle;
  final Color color;

  _GaugePainter({
    required this.angle,
    required this.maxAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.bgSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Active arc
    final progress = (angle.abs() / maxAngle).clamp(0.0, 1.0);
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      activePaint,
    );

    // Tick mark
    final tickAngle = math.pi * 0.75 + math.pi * 1.5 * progress;
    final tickPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final tickOffset = Offset(
      center.dx + radius * math.cos(tickAngle),
      center.dy + radius * math.sin(tickAngle),
    );
    canvas.drawCircle(tickOffset, 4, tickPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
