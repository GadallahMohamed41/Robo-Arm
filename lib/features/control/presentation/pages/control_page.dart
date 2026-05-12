import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../../connection/presentation/bloc/connection_bloc.dart';
import '../bloc/control_bloc.dart';
import '../widgets/arm_control_dashboard.dart';

class ControlPage extends StatelessWidget {
  final VoidCallback? onOpenConnection;

  const ControlPage({super.key, this.onOpenConnection});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControlBloc, ControlState>(
      builder: (context, state) {
        if (state.isEmergencyStopped) {
          return _EmergencyScreen(
            onResume: () =>
                context.read<ControlBloc>().add(const ResumeFromStop()),
          );
        }

        return BlocBuilder<ConnectionBloc, ConnectionState>(
          builder: (context, conn) {
            final connected = conn.isConnected;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDark
                  ? SystemUiOverlayStyle.light.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: AppColors.bgDeep,
                      systemNavigationBarIconBrightness: Brightness.light,
                    )
                  : SystemUiOverlayStyle.dark.copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: const Color(0xFFF8F9FC),
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ),
              child: Scaffold(
                  backgroundColor: isDark
                      ? AppColors.bgDeep
                      : const Color(0xFFF0F2F6),
                  body: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LabHeader(
                          connected: connected,
                          isDark: isDark,
                          deviceLabel: conn.connectedDevice?.name ??
                              conn.connectedWifiIp ??
                              'No device',
                        ),
                        if (!connected)
                          _ConnectionHintBar(
                            isDark: isDark,
                            onConnect: () {
                              final open = onOpenConnection;
                              if (open != null) {
                                open();
                              } else {
                                context.push(AppRoutes.connection);
                              }
                            },
                          ),
                        BlocBuilder<ConnectionBloc, ConnectionState>(
                          buildWhen: (p, c) => p.errorMessage != c.errorMessage,
                          builder: (context, st) {
                            final msg = st.errorMessage;
                            if (msg == null || msg.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                              child: Material(
                                color: AppColors.neonRed.withValues(
                                    alpha: isDark ? 0.14 : 0.08),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          size: 18,
                                          color: AppColors.neonRed),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          msg,
                                          style: TextStyle(
                                            fontFamily: 'Rajdhani',
                                            fontSize: 12,
                                            height: 1.25,
                                            color: isDark
                                                ? const Color(0xFFFFB4B8)
                                                : const Color(0xFF5C1018),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                            child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 420),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: Container(
                                key: ValueKey(isDark),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: isDark ? 0.55 : 0.1),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: ArmControlDashboard(
                                    key: const ValueKey('arm_dashboard'),
                                    servoAngles: state.servoAngles,
                                    slidersEnabled: true,
                                    onServoChanged: (protocolIndex, value) {
                                      context.read<ControlBloc>().add(
                                            ServoUpdated(
                                                protocolIndex, value),
                                          );
                                    },
                                    onServoReleased: connected
                                        ? (protocolIndex) => context
                                            .read<ControlBloc>()
                                            .transmitServoNow(protocolIndex)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _LabActionBar(
                          onHome: connected
                              ? () => context
                                  .read<ControlBloc>()
                                  .add(const GoHome())
                              : null,
                          onEmergency: () => context
                              .read<ControlBloc>()
                              .add(const EmergencyStop()),
                          onThemeToggle: () {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            themeNotifier.value =
                                isDark ? ThemeMode.light : ThemeMode.dark;
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
            );
          },
        );
      },
    );
  }
}

class _LabHeader extends StatelessWidget {
  final bool connected;
  final bool isDark;
  final String deviceLabel;

  const _LabHeader({
    required this.connected,
    required this.isDark,
    required this.deviceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.38);
    final titleColor = isDark ? AppColors.textPrimary : const Color(0xFF0D0D0F);
    final deviceMuted = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARM OS / CTRL',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3.2,
                  color: subtitle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Joint sequencer',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.6,
                  color: titleColor,
                  height: 1.05,
                ),
              ),
            ],
          ),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 132),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: connected
                            ? const Color(0xFF00A070).withValues(alpha: 0.45)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.black.withValues(alpha: 0.12)),
                      ),
                      color: connected
                          ? const Color(0xFF00A070).withValues(alpha: 0.08)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: connected
                                ? const Color(0xFF00A070)
                                : const Color(0xFFB0B4BE),
                            boxShadow: connected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00A070)
                                          .withValues(alpha: 0.45),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              connected ? 'ACTIVE' : 'STANDBY',
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: connected
                                    ? const Color(0xFF00664A)
                                    : const Color(0xFF6B7078),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deviceLabel,
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: deviceMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionHintBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConnect;

  const _ConnectionHintBar({required this.isDark, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Material(
        elevation: 0,
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onConnect,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth_searching_rounded,
                  size: 22,
                  color: AppColors.neonBlue.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'غير متصل. اضغط لفتح شاشة الربط وتوصيل البلوتوث بالجهاز.',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: isDark
                          ? AppColors.textSecondary
                          : Colors.black.withValues(alpha: 0.62),
                    ),
                  ),
                ),
                Text(
                  'اتصال',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.neonBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabActionBar extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback onEmergency;
  final VoidCallback onThemeToggle;
  final bool isDark;

  const _LabActionBar({
    required this.onHome,
    required this.onEmergency,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _BarBtn(
            icon: Icons.refresh_rounded,
            label: 'HOME',
            enabled: onHome != null,
            isDark: isDark,
            onTap: onHome,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onEmergency,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.neonRed.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  color: AppColors.neonRed.withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonRed.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emergency_rounded,
                        color: AppColors.neonRed, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'E–STOP',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.4,
                        color: AppColors.neonRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onThemeToggle,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 22,
                  color: isDark
                      ? AppColors.neonCyan
                      : const Color(0xFF2A2A2E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isDark;
  final VoidCallback? onTap;

  const _BarBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = enabled
        ? (isDark ? AppColors.textPrimary : const Color(0xFF1A1A1E))
        : AppColors.textMuted;
    final bg = enabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06))
        : (isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black12);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 88,
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyScreen extends StatefulWidget {
  final VoidCallback onResume;
  const _EmergencyScreen({required this.onResume});

  @override
  State<_EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<_EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.35, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Scaffold(
        backgroundColor: Color.lerp(
          Colors.white,
          AppColors.neonRed.withValues(alpha: 0.06),
          _pulse.value * 0.5,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 88,
                  color: AppColors.neonRed.withValues(alpha: _pulse.value),
                ),
                const SizedBox(height: 20),
                Text(
                  'EMERGENCY STOP',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neonRed.withValues(alpha: _pulse.value),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Servos parked at neutral. Resume when the workspace is clear.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 36),
                TextButton(
                  onPressed: widget.onResume,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonRed,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    side: const BorderSide(color: AppColors.neonRed, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'RESUME CONTROL',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
