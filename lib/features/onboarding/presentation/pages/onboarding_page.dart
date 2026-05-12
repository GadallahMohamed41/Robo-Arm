import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/neon_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      title: 'INITIALIZE',
      subtitle: 'SYSTEM STARTUP SEQUENCE',
      description: 'Establish secure connection to RoboArm via low-energy Bluetooth telemetry.',
      icon: Icons.power_settings_new_rounded,
      color: AppColors.neonCyan,
    ),
    _OnboardingItem(
      title: 'CALIBRATE',
      subtitle: 'PRECISION KINEMATICS',
      description: 'Access real-time angle adjustments and monitor core temperature data.',
      icon: Icons.tune_rounded,
      color: AppColors.neonBlue,
    ),
    _OnboardingItem(
      title: 'OVERRIDE',
      subtitle: 'MANUAL HUD CONTROL',
      description: 'Take full manual control with advanced joystick navigation and macro execution.',
      icon: Icons.gamepad_rounded,
      color: AppColors.neonPurple,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding_v3', true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background Glow based on current page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.5,
                colors: [
                  _items[_currentIndex].color.withOpacity(0.15),
                  AppColors.bgDeep,
                ],
              ),
            ),
          ),
          
          // Pages
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Holographic Icon
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withOpacity(0.05),
                        border: Border.all(color: item.color.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(color: item.color.withOpacity(0.2), blurRadius: 30, spreadRadius: 10),
                        ],
                      ),
                      child: Center(
                        child: Icon(item.icon, size: 64, color: item.color),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Titles
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(color: item.color.withOpacity(0.8), blurRadius: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: item.color,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Description
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 4,
                        width: _currentIndex == i ? 24 : 12,
                        decoration: BoxDecoration(
                          color: _currentIndex == i ? _items[i].color : AppColors.glassBorder,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: _currentIndex == i
                              ? [BoxShadow(color: _items[i].color.withOpacity(0.5), blurRadius: 4)]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  // Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentIndex == _items.length - 1
                        ? NeonButton(
                            key: const ValueKey('start'),
                            label: 'ENGAGE',
                            icon: Icons.rocket_launch_rounded,
                            color: _items[_currentIndex].color,
                            onPressed: _completeOnboarding,
                            width: 140,
                          )
                        : IconButton(
                            key: const ValueKey('next'),
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: _items[_currentIndex].color.withOpacity(0.2),
                              side: BorderSide(color: _items[_currentIndex].color.withOpacity(0.5)),
                            ),
                            onPressed: () {
                              _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
