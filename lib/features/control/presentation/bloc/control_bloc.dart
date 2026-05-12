import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../connection/presentation/bloc/connection_bloc.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class ControlEvent extends Equatable {
  const ControlEvent();
  @override
  List<Object?> get props => [];
}

/// Fired whenever any slider moves. [index] is 1–6, [value] is 0–180.
class ServoUpdated extends ControlEvent {
  final int index;
  final double value;
  const ServoUpdated(this.index, this.value);
  @override
  List<Object?> get props => [index, value];
}

/// Flush latest angle for one servo over Bluetooth immediately (slider released).
class ServoTransmitNow extends ControlEvent {
  final int index;
  const ServoTransmitNow(this.index);
  @override
  List<Object?> get props => [index];
}

class EmergencyStop extends ControlEvent {
  const EmergencyStop();
}

class ResumeFromStop extends ControlEvent {
  const ResumeFromStop();
}

class GoHome extends ControlEvent {
  const GoHome();
}

// ─── State ────────────────────────────────────────────────────────────────────

class ControlState extends Equatable {
  /// servo values indexed 0..5  →  protocol index 1..6
  final List<double> servoAngles;
  final bool isEmergencyStopped;

  const ControlState({
    this.servoAngles = const [90, 90, 90, 90, 90, 90],
    this.isEmergencyStopped = false,
  });

  ControlState copyWith({
    List<double>? servoAngles,
    bool? isEmergencyStopped,
  }) =>
      ControlState(
        servoAngles: servoAngles ?? this.servoAngles,
        isEmergencyStopped: isEmergencyStopped ?? this.isEmergencyStopped,
      );

  @override
  List<Object?> get props => [servoAngles, isEmergencyStopped];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  final ConnectionBloc connectionBloc;

  ControlBloc({required this.connectionBloc}) : super(const ControlState()) {
    on<ServoUpdated>(_onServoUpdated);
    on<ServoTransmitNow>(_onServoTransmitNow);
    on<EmergencyStop>(_onEmergencyStop);
    on<ResumeFromStop>(_onResumeFromStop);
    on<GoHome>(_onGoHome);
  }

  /// Same as [add]([ServoTransmitNow]) — kept for call-sites; use event directly if preferred.
  void transmitServoNow(int protocolIndex) =>
      add(ServoTransmitNow(protocolIndex));

  /// Protocol index 1–6, angle 0–180. Uses **LF only** — matches typical
  /// `Serial.readStringUntil('\n')` on Arduino (CR can break cheap BT modules).
  /// Index **2** = Lower arm / shoulder (`servo_1`, **PIN 8**) — extra resends for flaky SPP.
  void _sendServoLine(int protocolIndex, int angleDeg) {
    final a = angleDeg.clamp(0, 180);
    final line = '$protocolIndex:$a\n';
    connectionBloc.add(SendData(line));
    if (protocolIndex != 2) return;
    for (final ms in [25, 55]) {
      Future<void>.delayed(Duration(milliseconds: ms), () {
        if (isClosed || state.isEmergencyStopped) return;
        connectionBloc.add(SendData(line));
      });
    }
  }

  void _onServoUpdated(ServoUpdated event, Emitter<ControlState> emit) {
    if (state.isEmergencyStopped) return;
    final angles = List<double>.from(state.servoAngles);
    final v = event.value.clamp(0.0, 180.0);
    angles[event.index - 1] = v;
    emit(state.copyWith(servoAngles: angles));

    _sendServoLine(event.index, v.round());
  }

  void _onServoTransmitNow(
      ServoTransmitNow event, Emitter<ControlState> emit) {
    if (state.isEmergencyStopped) return;
    final idx = event.index;
    final sent = state.servoAngles[idx - 1].round().clamp(0, 180);
    _sendServoLine(idx, sent);
  }

  void _onEmergencyStop(EmergencyStop event, Emitter<ControlState> emit) {
    emit(state.copyWith(isEmergencyStopped: true));
    for (int i = 1; i <= 6; i++) {
      _sendServoLine(i, 90);
    }
  }

  void _onResumeFromStop(ResumeFromStop event, Emitter<ControlState> emit) {
    emit(state.copyWith(isEmergencyStopped: false));
  }

  void _onGoHome(GoHome event, Emitter<ControlState> emit) {
    if (state.isEmergencyStopped) return;
    emit(state.copyWith(servoAngles: [90, 90, 90, 90, 90, 90]));
    for (int i = 1; i <= 6; i++) {
      _sendServoLine(i, 90);
    }
  }
}
