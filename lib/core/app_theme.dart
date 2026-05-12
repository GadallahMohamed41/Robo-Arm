import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary Neon
  static const neonCyan = Color(0xFF00C2CC);
  static const neonBlue = Color(0xFF0080FF);
  static const neonPurple = Color(0xFF7B2FFF);
  static const neonGreen = Color(0xFF00C97A);
  static const neonRed = Color(0xFFFF003C);
  static const neonOrange = Color(0xFFFF6B00);

  // Dark Backgrounds
  static const bgDeep = Color(0xFF030812);
  static const bgDark = Color(0xFF060E1E);
  static const bgCard = Color(0xFF0A1628);
  static const bgCardLight = Color(0xFF0F1F3D);
  static const bgSurface = Color(0xFF111E35);

  // Glass
  static const glassWhite = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x1A00F5FF);
  static const glassHighlight = Color(0x26FFFFFF);

  // Dark Text
  static const textPrimary = Color(0xFFEBF4FF);
  static const textSecondary = Color(0xFF7A9CC4);
  static const textMuted = Color(0xFF3D5A7A);
  static const textNeon = Color(0xFF00F5FF);

  // Status
  static const statusOnline = Color(0xFF00FF88);
  static const statusWarning = Color(0xFFFFAA00);
  static const statusError = Color(0xFFFF003C);
  static const statusIdle = Color(0xFF7A9CC4);

  // Gradients
  static const gradientCyan = LinearGradient(
    colors: [neonCyan, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // ── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonBlue,
        surface: AppColors.bgCard,
        error: AppColors.neonRed,
        onPrimary: AppColors.bgDeep,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Rajdhani',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.neonCyan),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonBlue,
        secondary: Color(0xFF0055CC),
        surface: Colors.white,
        error: AppColors.neonRed,
        onPrimary: Colors.white,
        onSurface: Color(0xFF0D1B2A),
      ),
      fontFamily: 'Rajdhani',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0055CC)),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDDE3F0),
        thickness: 1,
      ),
    );
  }
}
