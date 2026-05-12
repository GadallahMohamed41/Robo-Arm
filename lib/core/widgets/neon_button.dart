// NEW FILE: lib/core/widgets/neon_button.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium neon-glowing button.
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double width;
  final double height;
  final IconData? icon;
  final bool isLoading;
  final double fontSize;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.neonCyan,
    this.width = double.infinity,
    this.height = 52,
    this.icon,
    this.isLoading = false,
    this.fontSize = 14,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.8),
                    widget.color.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.color.withValues(alpha: 0.4 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color:
                        widget.color.withValues(alpha: 0.2 * _glowAnimation.value),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.color),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon,
                              color: AppColors.bgDeep, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bgDeep,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Emergency STOP button with dramatic styling.
class EmergencyStopButton extends StatefulWidget {
  final VoidCallback onPressed;

  const EmergencyStopButton({super.key, required this.onPressed});

  @override
  State<EmergencyStopButton> createState() => _EmergencyStopButtonState();
}

class _EmergencyStopButtonState extends State<EmergencyStopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonRed.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.neonRed.withValues(alpha: _pulseAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonRed.withValues(
                      alpha: 0.5 * _pulseAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stop_circle_outlined,
                  color: AppColors.neonRed.withValues(alpha: _pulseAnimation.value),
                  size: 28,
                ),
                const SizedBox(height: 2),
                Text(
                  'STOP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color:
                        AppColors.neonRed.withValues(alpha: _pulseAnimation.value),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
