// UPDATED FILE: lib/core/router/app_router.dart
// Super advanced linear routing.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/control/presentation/pages/control_page.dart';
import '../../features/connection/presentation/pages/connection_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const connection = '/connection';
  static const control = '/control';
  static const home = '/home';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;
    final isSplash = state.matchedLocation == AppRoutes.splash;
    final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

    // Always allow splash & onboarding
    if (isSplash || isOnboarding) return null;

    // If not logged in, only allow auth routes
    if (user == null && !isAuthRoute) return AppRoutes.login;

    // If logged in but trying to access auth routes, send to home
    if (user != null && isAuthRoute) return AppRoutes.home;

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _buildPage(const SplashPage(), state),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => _buildPage(const HomePage(), state),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) =>
          _buildPage(const OnboardingPage(), state),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _buildPage(const LoginPage(), state),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) =>
          _buildPage(const RegisterPage(), state),
    ),
    GoRoute(
      path: AppRoutes.connection,
      pageBuilder: (context, state) =>
          _buildPage(const ConnectionPage(), state),
    ),
    GoRoute(
      path: AppRoutes.control,
      pageBuilder: (context, state) =>
          _buildPage(const ControlPage(), state),
    ),
  ],
);

CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
            parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}