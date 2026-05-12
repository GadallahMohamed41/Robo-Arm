import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import 'joint_channel.dart';

/// Horizontal lab-style slider — theme-aware for light / dark OS look.
class IndustrialJointSlider extends StatelessWidget {
  final JointChannel channel;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback? onInteractionEnd;
  final bool enabled;

  const IndustrialJointSlider({
    super.key,
    required this.channel,
    required this.value,
    required this.onChanged,
    this.onInteractionEnd,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 180.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final labelMuted = isDark
        ? const Color(0xFF9AA3B8)
        : const Color(0xFF9A9CA8);
    final subMuted = isDark
        ? Colors.white.withValues(alpha: 0.38)
        : Colors.black.withValues(alpha: 0.32);
    final valueColor =
        isDark ? AppColors.textPrimary : const Color(0xFF0D0D0F);
    final trackActive =
        isDark ? AppColors.neonCyan : const Color(0xFF0A0A0C);
    final trackInactive =
        isDark ? const Color(0xFF2A3548) : const Color(0xFFE4E5EA);
    final tickColor = isDark
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.26);

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        channel.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.85,
                          color: labelMuted,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${channel.servoId} · PIN ${channel.arduinoPin}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.45,
                          color: subMuted,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${v.round()}°',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.35,
                    color: valueColor,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Theme(
              data: theme.copyWith(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: trackActive,
                  inactiveTrackColor: trackInactive,
                  thumbColor: isDark
                      ? const Color(0xFFB8C0CC)
                      : const Color(0xFF5C5E66),
                  overlayColor:
                      (isDark ? AppColors.neonCyan : Colors.black)
                          .withValues(alpha: 0.08),
                  trackShape: const RoundedRectSliderTrackShape(),
                  thumbShape: _IndustrialThumbShape(isDark: isDark),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  value: v,
                  min: 0,
                  max: 180,
                  onChanged: enabled ? onChanged : null,
                  onChangeEnd: enabled
                      ? (_) {
                          onInteractionEnd?.call();
                        }
                      : null,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0°',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 8.5,
                    color: tickColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '180°',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 8.5,
                    color: tickColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IndustrialThumbShape extends SliderComponentShape {
  final bool isDark;

  _IndustrialThumbShape({this.isDark = false});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(22, 11);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 22, height: 11),
      const Radius.circular(5),
    );

    canvas.drawRRect(
      rect.shift(const Offset(0, 1.2)),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final colors = isDark
        ? const [
            Color(0xFFE2E8F4),
            Color(0xFF7A8494),
            Color(0xFF2A3038),
          ]
        : const [
            Color(0xFFB8B9C2),
            Color(0xFF6A6B74),
            Color(0xFF2E2F35),
          ];

    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect.outerRect),
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..color = isDark
            ? const Color(0xFF00C2CC).withValues(alpha: 0.45)
            : const Color(0xFF1A1A1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    final hi = RRect.fromRectAndRadius(
      Rect.fromLTWH(rect.left + 4, rect.top + 2.5, 5, 2.2),
      const Radius.circular(1.1),
    );
    canvas.drawRRect(
      hi,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
    );
  }
}
