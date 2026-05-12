import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_theme.dart';
import '../bloc/connection_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');
  final TextEditingController _portController = TextEditingController(text: '8080');

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.connectionType == ConnectionType.bluetooth ? 'BLUETOOTH' : 'WIFI',
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neonCyan,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            state.isConnected
                                ? 'LINKED — ${state.connectionType == ConnectionType.wifi ? state.connectedWifiIp : state.connectedDevice?.name ?? ""}'
                                : 'FIND & CONNECT DEVICES',
                            style: const TextStyle(
                              fontFamily: 'Rajdhani',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      // Logout
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textMuted.withOpacity(0.08),
                            border: Border.all(
                                color: AppColors.textMuted.withOpacity(0.25)),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Toggle Connection Type ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        _buildTab(
                          context: context,
                          label: 'BLUETOOTH',
                          icon: Icons.bluetooth_rounded,
                          isSelected: state.connectionType == ConnectionType.bluetooth,
                          onTap: () => context.read<ConnectionBloc>().add(const SwitchConnectionType(ConnectionType.bluetooth)),
                        ),
                        _buildTab(
                          context: context,
                          label: 'WIFI',
                          icon: Icons.wifi_rounded,
                          isSelected: state.connectionType == ConnectionType.wifi,
                          onTap: () => context.read<ConnectionBloc>().add(const SwitchConnectionType(ConnectionType.wifi)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Status / Error Banner ──
                if (state.errorMessage != null)
                  _Banner(
                    message: state.errorMessage!,
                    color: AppColors.neonRed,
                    icon: Icons.warning_rounded,
                  ),

                if (state.isConnected)
                  if (state.connectionType == ConnectionType.bluetooth && state.connectedDevice != null)
                    _Banner(
                      message: 'Connected to ${state.connectedDevice!.name}',
                      color: AppColors.neonGreen,
                      icon: Icons.bluetooth_connected_rounded,
                    )
                  else if (state.connectionType == ConnectionType.wifi && state.connectedWifiIp != null)
                    _Banner(
                      message: 'Connected to ${state.connectedWifiIp}',
                      color: AppColors.neonGreen,
                      icon: Icons.wifi_rounded,
                    ),

                // ── Content ──
                if (state.connectionType == ConnectionType.bluetooth) ...[
                  // ── Search Button ──
                  Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: _SearchButton(
                    isScanning: state.isScanning,
                    onTap: () {
                      if (state.isScanning) {
                        context
                            .read<ConnectionBloc>()
                            .add(const StopScan());
                      } else {
                        context
                            .read<ConnectionBloc>()
                            .add(const StartScan());
                      }
                    },
                  ),
                ),

                // ── Devices List ──
                Expanded(
                  child: state.discoveredDevices.isEmpty
                      ? _EmptyState(isScanning: state.isScanning)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: state.discoveredDevices.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final device = state.discoveredDevices[i];
                            final isConnecting = state.isConnecting &&
                                state.connectedDevice?.id == device.id;
                            final isConnected =
                                state.connectedDevice?.id == device.id;
                            return _DeviceCard(
                              device: device,
                              isConnecting: isConnecting,
                              isConnected: isConnected,
                              onConnect: () => context
                                  .read<ConnectionBloc>()
                                  .add(ConnectToDevice(device)),
                              onDisconnect: () => context
                                  .read<ConnectionBloc>()
                                  .add(const DisconnectDevice()),
                            );
                          },
                        ),
                ),
              ] else ...[
                  Expanded(child: _buildWifiForm(context, state)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.neonCyan.withOpacity(0.5)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.neonCyan : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWifiForm(BuildContext context, ConnectionState state) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROBOT IP ADDRESS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Rajdhani'),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.textMuted.withOpacity(0.05),
              prefixIcon: const Icon(Icons.router_rounded, color: AppColors.neonCyan, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.neonCyan),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'PORT',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontFamily: 'Rajdhani'),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.textMuted.withOpacity(0.05),
              prefixIcon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.neonCyan, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.neonCyan),
              ),
            ),
          ),
          const Spacer(),
          if (state.isConnected && state.connectionType == ConnectionType.wifi)
            GestureDetector(
              onTap: () => context.read<ConnectionBloc>().add(const DisconnectDevice()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.1),
                  border: Border.all(color: AppColors.neonRed, width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.neonRed.withOpacity(0.25), blurRadius: 20),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'DISCONNECT WIFI',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonRed,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: state.isConnecting 
                ? null 
                : () {
                    final ip = _ipController.text.trim();
                    final port = int.tryParse(_portController.text.trim()) ?? 8080;
                    context.read<ConnectionBloc>().add(ConnectToWifi(ip: ip, port: port));
                  },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: state.isConnecting ? AppColors.textMuted.withOpacity(0.1) : AppColors.neonCyan.withOpacity(0.1),
                  border: Border.all(
                    color: state.isConnecting ? AppColors.textMuted : AppColors.neonCyan, 
                    width: 1.5
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!state.isConnecting)
                      BoxShadow(color: AppColors.neonCyan.withOpacity(0.25), blurRadius: 20),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isConnecting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan),
                      )
                    else
                      const Icon(Icons.wifi_rounded, color: AppColors.neonCyan, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      state.isConnecting ? 'CONNECTING...' : 'CONNECT TO WIFI',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: state.isConnecting ? AppColors.textMuted : AppColors.neonCyan,
                        letterSpacing: 2,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonRed.withOpacity(0.4)),
        ),
        title: const Text(
          'SIGN OUT',
          style: TextStyle(
              fontFamily: 'Orbitron',
              color: AppColors.neonRed,
              fontSize: 15,
              letterSpacing: 2),
        ),
        content: const Text(
          'Terminate session and sign out?',
          style: TextStyle(
              fontFamily: 'Rajdhani',
              color: AppColors.textSecondary,
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL',
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppColors.textMuted,
                    fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(const SignOutRequested());
              context.go('/login');
            },
            child: const Text('CONFIRM',
                style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppColors.neonRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Search Button ─────────────────────────────────────────────────────────────

class _SearchButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onTap;

  const _SearchButton({required this.isScanning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isScanning ? AppColors.neonRed : AppColors.neonCyan;
    final label = isScanning ? 'STOP SEARCH' : 'SEARCH FOR DEVICES';
    final icon =
        isScanning ? Icons.stop_circle_rounded : Icons.bluetooth_searching_rounded;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isScanning
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color),
                  )
                : Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Device Card ───────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final BleDevice device;
  final bool isConnecting;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceCard({
    required this.device,
    required this.isConnecting,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.neonGreen : AppColors.neonBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(
              isConnected
                  ? Icons.bluetooth_connected_rounded
                  : Icons.bluetooth_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Name & ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  device.id,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Signal bars
          _SignalBars(bars: device.signalBars, color: color),
          const SizedBox(width: 12),

          // Action Button
          if (isConnecting)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else if (isConnected)
            GestureDetector(
              onTap: onDisconnect,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.1),
                  border: Border.all(color: AppColors.neonRed),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('DISCONNECT',
                    style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 9,
                        color: AppColors.neonRed,
                        fontWeight: FontWeight.w700)),
              ),
            )
          else
            GestureDetector(
              onTap: onConnect,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('CONNECT',
                    style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Signal Bars ───────────────────────────────────────────────────────────────

class _SignalBars extends StatelessWidget {
  final int bars; // 1-4
  final Color color;

  const _SignalBars({required this.bars, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final active = i < bars;
        return Container(
          width: 4,
          height: 6.0 + i * 4,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: active ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isScanning;
  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isScanning
                ? Icons.bluetooth_searching_rounded
                : Icons.bluetooth_disabled_rounded,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? 'SCANNING...' : 'NO DEVICES FOUND',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isScanning
                ? 'Looking for nearby Bluetooth devices'
                : 'Press SEARCH to find nearby devices',
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Banner ───────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _Banner(
      {required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  fontFamily: 'Rajdhani',
                  color: color,
                  fontSize: 12,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
