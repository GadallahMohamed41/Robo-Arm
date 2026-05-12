import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import 'industrial_joint_slider.dart';
import 'joint_channel.dart';

/// Left: fixed arm illustration. Right: six joint sliders. Connector lines align per row.
class ArmControlDashboard extends StatefulWidget {
  final List<double> servoAngles;
  final void Function(int protocolIndex, double value) onServoChanged;
  /// Called when user releases slider thumb (optional e.g. BT flush).
  final void Function(int protocolIndex)? onServoReleased;
  final bool slidersEnabled;

  const ArmControlDashboard({
    super.key,
    required this.servoAngles,
    required this.onServoChanged,
    this.onServoReleased,
    this.slidersEnabled = true,
  });

  @override
  State<ArmControlDashboard> createState() => _ArmControlDashboardState();
}

class _ArmControlDashboardState extends State<ArmControlDashboard> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _jointKeys =
      List<GlobalKey>.generate(6, (_) => GlobalKey());
  final List<GlobalKey> _sliderKeys =
      List<GlobalKey>.generate(6, (_) => GlobalKey());

  List<_Segment> _segments = const [];
  bool _postFrameScheduled = false;
  int _segmentLayoutPasses = 0;

  void _scheduleSegmentRecompute() {
    if (_postFrameScheduled) return;
    _postFrameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postFrameScheduled = false;
      if (!mounted) return;
      _recomputeSegments();
      if (_segments.length < 6 && _segmentLayoutPasses < 16) {
        _segmentLayoutPasses++;
        _scheduleSegmentRecompute();
      } else if (_segments.length == 6) {
        _segmentLayoutPasses = 0;
      }
    });
  }

  void _recomputeSegments() {
    final stackCtx = _stackKey.currentContext;
    if (stackCtx == null) return;
    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final next = <_Segment>[];
    for (var i = 0; i < 6; i++) {
      final joint =
          _jointKeys[i].currentContext?.findRenderObject() as RenderBox?;
      final slide =
          _sliderKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (joint == null ||
          slide == null ||
          !joint.hasSize ||
          !slide.hasSize) {
        continue;
      }

      final jc = joint.localToGlobal(Offset.zero) +
          Offset(joint.size.width / 2, joint.size.height / 2);
      final sc = slide.localToGlobal(Offset.zero) +
          Offset(0, slide.size.height * 0.46);

      final start = stackBox.globalToLocal(jc);
      final end = stackBox.globalToLocal(sc);

      next.add(_Segment(start, end));
    }

    if (!_segmentsEqual(_segments, next)) {
      setState(() => _segments = next);
    }
  }

  bool _segmentsEqual(List<_Segment> a, List<_Segment> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i].start - b[i].start).distance > 0.5) return false;
      if ((a[i].end - b[i].end).distance > 0.5) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        _scheduleSegmentRecompute();
        return Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 52,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: const Offset(-42, 0),
                          child: Transform.scale(
                            scale: 1.12,
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/arm.jpeg',
                              fit: BoxFit.cover,
                              alignment: const Alignment(-0.88, -0.06),
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: const [0.0, 0.28, 0.65, 1.0],
                              colors: isDark
                                  ? [
                                      Colors.black.withValues(alpha: 0.45),
                                      Colors.transparent,
                                      AppColors.bgCard.withValues(alpha: 0.88),
                                      AppColors.bgCard,
                                    ]
                                  : [
                                      Colors.black.withValues(alpha: 0.07),
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.78),
                                      Colors.white,
                                    ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: const [0.0, 0.5, 1.0],
                              colors: [
                                AppColors.neonBlue.withValues(
                                    alpha: isDark ? 0.12 : 0.09),
                                Colors.transparent,
                                Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.03),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LabsCircuitPainter(isDark: isDark),
                        ),
                      ),
                      Column(
                        children: List.generate(6, (i) {
                          return Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: KeyedSubtree(
                                  key: _jointKeys[i],
                                  child: _JointAnchorDot(isDark: isDark),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 48,
                  child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgCard : Colors.white,
                        border: Border(
                          left: BorderSide(
                            color: isDark
                                ? const Color(0xFF1A2A42)
                                : const Color(0xFFE6E8EE),
                          ),
                        ),
                      ),
                      child: Column(
                      children: List.generate(6, (i) {
                        final ch = kJointChannelsDisplayTopToBottom[i];
                        final angle =
                            widget.servoAngles[ch.protocolIndex - 1];
                        return Expanded(
                          child: KeyedSubtree(
                            key: _sliderKeys[i],
                            child: IndustrialJointSlider(
                              channel: ch,
                              value: angle,
                              enabled: widget.slidersEnabled,
                              onChanged: (v) =>
                                  widget.onServoChanged(ch.protocolIndex, v),
                              onInteractionEnd: widget.onServoReleased != null
                                  ? () =>
                                      widget.onServoReleased!(ch.protocolIndex)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      segments: _segments,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
        );
      },
    );
  }
}

class _JointAnchorDot extends StatelessWidget {
  final bool isDark;

  const _JointAnchorDot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.neonCyan.withValues(alpha: 0.35) : const Color(0xFF0A0A0C),
        border: Border.all(
          color: isDark ? AppColors.neonCyan : Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.neonCyan : Colors.black)
                .withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: isDark ? 6 : 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// Subtle “lab PCB” lines behind the arm photo.
class _LabsCircuitPainter extends CustomPainter {
  final bool isDark;

  _LabsCircuitPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final line = Paint()
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..color = AppColors.neonBlue.withValues(alpha: isDark ? 0.14 : 0.1);

    for (var i = 0; i < 7; i++) {
      final y = h * (0.12 + i * 0.11);
      canvas.drawLine(Offset(0, y), Offset(w * 0.88, y), line);
    }
    for (var i = 0; i < 6; i++) {
      final x = w * (0.06 + i * 0.14);
      canvas.drawLine(Offset(x, 0), Offset(x, h * 0.92), line);
    }
    final node = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: isDark ? 0.2 : 0.12);
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 4; j++) {
        canvas.drawCircle(
          Offset(w * (0.1 + i * 0.16), h * (0.2 + j * 0.18)),
          1.2,
          node,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LabsCircuitPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _Segment {
  final Offset start;
  final Offset end;

  const _Segment(this.start, this.end);
}

class _ConnectorPainter extends CustomPainter {
  final List<_Segment> segments;
  final bool isDark;

  _ConnectorPainter({required this.segments, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = isDark
        ? const Color(0x66000000)
        : const Color(0x22000000);
    final stroke =
        isDark ? const Color(0xFF6A7A90) : const Color(0xFF000000);

    for (final seg in segments) {
      final mid = Offset(
        (seg.start.dx + seg.end.dx) / 2,
        (seg.start.dy + seg.end.dy) / 2,
      );

      final path = Path()
        ..moveTo(seg.start.dx, seg.start.dy)
        ..quadraticBezierTo(mid.dx, seg.start.dy, seg.end.dx, seg.end.dy);

      canvas.drawPath(
        path,
        Paint()
          ..color = shadow
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..strokeWidth = 0.85
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _ConnectorPainter) return true;
    if (oldDelegate.isDark != isDark) return true;
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].start != segments[i].start ||
          oldDelegate.segments[i].end != segments[i].end) {
        return true;
      }
    }
    return false;
  }
}
