// NEW FILE: lib/core/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A glassmorphism card with optional neon border glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? glowColor;
  final double glowRadius;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
    this.borderWidth = 1,
    this.glowColor,
    this.glowRadius = 8,
    this.gradient,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor =
        glowColor ?? AppColors.neonCyan.withValues(alpha: 0.3);
    final effectiveBorderColor = borderColor ?? AppColors.glassBorder;

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ??
            const LinearGradient(
              colors: [AppColors.bgCard, AppColors.bgCardLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor,
            blurRadius: glowRadius,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
