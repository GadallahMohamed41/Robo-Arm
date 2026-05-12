import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../connection/presentation/bloc/connection_bloc.dart';
import '../../../connection/presentation/pages/connection_page.dart';
import '../../../control/presentation/pages/control_page.dart';
import '../../../../core/app_theme.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Start on Control Page by default

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionBloc, ConnectionState>(
      listener: (context, state) {
        // Automatically switch to Control tab when successfully connected
        if (state.isConnected && _currentIndex == 1) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _currentIndex = 0;
              });
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            ControlPage(
              onOpenConnection: () => setState(() => _currentIndex = 1),
            ),
            const ConnectionPage(),
          ],
        ),
        bottomNavigationBar: _SciFiBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _SciFiBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SciFiBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: AppColors.neonCyan.withOpacity(0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.gamepad_rounded,
                label: 'HUD CONTROL',
                isActive: currentIndex == 0,
                color: AppColors.neonCyan,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.radar_rounded,
                label: 'NODE SCAN',
                isActive: currentIndex == 1,
                color: AppColors.neonBlue,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                  color: isActive ? color : Colors.transparent,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)]
                    : [],
              ),
              child: Icon(
                icon,
                color: isActive ? color : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
