// NEW FILE: lib/features/control/domain/entities/arm_state.dart

import 'package:equatable/equatable.dart';

/// Represents the full state of the robotic arm joints.
class ArmState extends Equatable {
  final double baseRotation;    // 0 to 180 (90 = center)
  final double shoulderAngle;   // 0 to 180
  final double elbowAngle;      // 0 to 180
  final double gripperOpen;     // 0 to 100 (%)
  final bool isMoving;
  final bool isEmergencyStopped;
  final OperationMode mode;

  const ArmState({
    this.baseRotation = 90,
    this.shoulderAngle = 0,
    this.elbowAngle = 0,
    this.gripperOpen = 50,
    this.isMoving = false,
    this.isEmergencyStopped = false,
    this.mode = OperationMode.manual,
  });

  ArmState copyWith({
    double? baseRotation,
    double? shoulderAngle,
    double? elbowAngle,
    double? gripperOpen,
    bool? isMoving,
    bool? isEmergencyStopped,
    OperationMode? mode,
  }) {
    return ArmState(
      baseRotation: baseRotation ?? this.baseRotation,
      shoulderAngle: shoulderAngle ?? this.shoulderAngle,
      elbowAngle: elbowAngle ?? this.elbowAngle,
      gripperOpen: gripperOpen ?? this.gripperOpen,
      isMoving: isMoving ?? this.isMoving,
      isEmergencyStopped: isEmergencyStopped ?? this.isEmergencyStopped,
      mode: mode ?? this.mode,
    );
  }

  /// Returns to safe home position.
  static const ArmState home = ArmState(
    baseRotation: 90,
    shoulderAngle: 90,
    elbowAngle: 90,
    gripperOpen: 90,
  );

  @override
  List<Object?> get props => [
    baseRotation, shoulderAngle, elbowAngle,
    gripperOpen, isMoving,
    isEmergencyStopped, mode,
  ];
}

enum OperationMode { manual, auto, record }

/// Telemetry data from the robot.
class RobotTelemetry extends Equatable {
  final double batteryLevel;      // 0-100
  final double temperature;       // Celsius
  final double signalStrength;    // 0-100
  final List<ServoStatus> servos;
  final DateTime timestamp;

  const RobotTelemetry({
    this.batteryLevel = 85.5,
    this.temperature = 42.3,
    this.signalStrength = 78.0,
    this.servos = const [],
    required this.timestamp,
  });

  factory RobotTelemetry.mock() {
    return RobotTelemetry(
      batteryLevel: 85.5,
      temperature: 42.3,
      signalStrength: 78.0,
      servos: const [
        ServoStatus(id: 1, name: 'BASE', current: 0.34, temperature: 38.2, isOk: true),
        ServoStatus(id: 2, name: 'SHOULDER', current: 0.52, temperature: 41.8, isOk: true),
        ServoStatus(id: 3, name: 'ELBOW', current: 0.41, temperature: 39.5, isOk: true),
        ServoStatus(id: 4, name: 'GRIPPER', current: 0.19, temperature: 35.6, isOk: true),
      ],
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [batteryLevel, temperature, signalStrength, servos, timestamp];
}

class ServoStatus extends Equatable {
  final int id;
  final String name;
  final double current;       // Amps
  final double temperature;   // Celsius
  final bool isOk;

  const ServoStatus({
    required this.id,
    required this.name,
    required this.current,
    required this.temperature,
    required this.isOk,
  });

  @override
  List<Object?> get props => [id, name, current, temperature, isOk];
}

/// A device found during scanning.
class RoboticDevice extends Equatable {
  final String id;
  final String name;
  final String address;
  final int rssi;
  final DeviceType type;
  final bool isPaired;

  const RoboticDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.rssi,
    required this.type,
    this.isPaired = false,
  });

  int get signalBars {
    if (rssi >= -50) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    return 1;
  }

  static List<RoboticDevice> mockDevices() => [
    const RoboticDevice(
      id: '1', name: 'ROBO-ARM-001', address: '00:1A:7D:DA:71:13',
      rssi: -48, type: DeviceType.bluetooth, isPaired: true,
    ),
    const RoboticDevice(
      id: '2', name: 'ARM-CTRL-WiFi', address: '192.168.1.101',
      rssi: -62, type: DeviceType.wifi, isPaired: false,
    ),
    const RoboticDevice(
      id: '3', name: 'RobotArm-PRO', address: '00:1A:7D:DA:71:28',
      rssi: -71, type: DeviceType.bluetooth, isPaired: false,
    ),
  ];

  @override
  List<Object?> get props => [id, name, address, rssi, type, isPaired];
}

enum DeviceType { bluetooth, wifi }