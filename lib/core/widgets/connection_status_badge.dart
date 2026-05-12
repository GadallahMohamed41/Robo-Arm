// NEW FILE: lib/core/widgets/connection_status_badge.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ConnectionStatus { connected, connecting, disconnected, error }

class ConnectionStatusBadge extends StatefulWidget {
  final ConnectionStatus status;
  final String? deviceName;

  const ConnectionStatusBadge({
    super.key,
    required this.status,
    this.deviceName,
  });

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.status == ConnectionStatus.connecting) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ConnectionStatus.connecting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return AppColors.statusOnline;
      case ConnectionStatus.connecting:
        return AppColors.statusWarning;
      case ConnectionStatus.disconnected:
        return AppColors.textMuted;
      case ConnectionStatus.error:
        return AppColors.statusError;
    }
  }

  String get _statusLabel {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return widget.deviceName != null ? 'CONNECTED · ${widget.deviceName}' : 'CONNECTED';
      case ConnectionStatus.connecting:
        return 'CONNECTING...';
      case ConnectionStatus.disconnected:
        return 'DISCONNECTED';
      case ConnectionStatus.error:
        return 'ERROR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final opacity = widget.status == ConnectionStatus.connecting
            ? _pulseAnimation.value
            : 1.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _statusColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor.withValues(alpha: opacity),
                  boxShadow: [
                    BoxShadow(
                      color: _statusColor.withValues(alpha: 0.8 * opacity),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _statusLabel,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: _statusColor.withValues(alpha: opacity),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
