// UPDATED FILE: lib/features/splash/presentation/pages/splash_page.dart
// Checks Firebase Auth state after animation — sends to login or home.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/router/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _ringRot;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _ringRot = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.linear));

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeIn)));

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('has_seen_onboarding_v3') ?? false;
    if (!mounted) return;

    if (!seenOnboarding) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // Check auth state
    final user = FirebaseAuth.instance.currentUser;
    context.go(user != null ? AppRoutes.home : AppRoutes.login);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Radial gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [AppColors.bgCard, AppColors.bgDeep],
              ),
            ),
          ),
          // Grid overlay
          CustomPaint(
            painter: _GridPainter(),
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rotating rings + logo
                SizedBox(
                  width: 180,
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _ringRot,
                    builder: (context, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer dashed ring
                        Transform.rotate(
                          angle: _ringRot.value,
                          child: const CustomPaint(
                            painter: _RingPainter(
                                color: AppColors.neonCyan,
                                strokeWidth: 2,
                                dashCount: 12),
                            size: Size(180, 180),
                          ),
                        ),
                        // Inner counter-rotate
                        Transform.rotate(
                          angle: -_ringRot.value * 0.6,
                          child: CustomPaint(
                            painter: _RingPainter(
                                color: AppColors.neonBlue.withOpacity(0.6),
                                strokeWidth: 1.5,
                                dashCount: 8,
                                radius: 70),
                            size: const Size(180, 180),
                          ),
                        ),
                        // Logo
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(colors: [
                                  AppColors.neonCyan,
                                  AppColors.neonBlue
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.neonCyan
                                          .withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 8)
                                ],
                              ),
                              child: const Icon(
                                  Icons.precision_manufacturing_rounded,
                                  color: AppColors.bgDeep,
                                  size: 44),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // App name
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.gradientCyan.createShader(b),
                          child: const Text('ROBOARM',
                              style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 6)),
                        ),
                        const SizedBox(height: 4),
                        const Text('PRO CONTROL SYSTEM',
                            style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 4)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Loading bar
                FadeTransition(
                  opacity: _textOpacity,
                  child: SizedBox(width: 160, child: _LoadingBar()),
                ),
              ],
            ),
          ),
          // Version
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: const Text('v1.0.0  ·  POWERED BY FIREBASE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading bar ───────────────────────────────────────────────────────────────

class _LoadingBar extends StatefulWidget {
  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..forward();
    _progress = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) => Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 3, color: AppColors.bgSurface),
                FractionallySizedBox(
                  widthFactor: _progress.value,
                  child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                          gradient: AppColors.gradientCyan)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'INITIALIZING... ${(_progress.value * 100).toInt()}%',
            style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 8,
                color: AppColors.neonCyan,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double? radius;
  const _RingPainter(
      {required this.color,
      required this.strokeWidth,
      required this.dashCount,
      this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = radius ?? size.width / 2 - strokeWidth;
    const gapFrac = 0.3;
    final dashAngle = (2 * math.pi / dashCount) * (1 - gapFrac);
    final gapAngle = (2 * math.pi / dashCount) * gapFrac;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    double start = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), start,
          dashAngle, false, paint);
      start += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.03)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
