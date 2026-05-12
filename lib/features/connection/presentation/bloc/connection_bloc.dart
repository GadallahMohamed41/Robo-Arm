import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

enum ConnectionType { bluetooth, wifi }

// ── Domain model (keeps UI-layer decoupled from BLE primitives) ───────────────

class BleDevice extends Equatable {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDevice rawDevice;

  const BleDevice({
    required this.id,
    required this.name,
    this.rssi = -50,
    required this.rawDevice,
  });

  int get signalBars {
    if (rssi >= -50) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    return 1;
  }

  @override
  List<Object?> get props => [id, rssi];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object?> get props => [];
}

class StartScan extends ConnectionEvent {
  const StartScan();
}

class StopScan extends ConnectionEvent {
  const StopScan();
}

class ConnectToDevice extends ConnectionEvent {
  final BleDevice device;
  const ConnectToDevice(this.device);
  @override
  List<Object?> get props => [device.id];
}

class DisconnectDevice extends ConnectionEvent {
  const DisconnectDevice();
}

class SwitchConnectionType extends ConnectionEvent {
  final ConnectionType type;
  const SwitchConnectionType(this.type);
  @override
  List<Object?> get props => [type];
}

class ConnectToWifi extends ConnectionEvent {
  final String ip;
  final int port;
  const ConnectToWifi({required this.ip, required this.port});
  @override
  List<Object?> get props => [ip, port];
}

class SendData extends ConnectionEvent {
  final String data;
  const SendData(this.data);
  @override
  List<Object?> get props => [data];
}

class _ScanResultsUpdated extends ConnectionEvent {
  final List<BleDevice> devices;
  const _ScanResultsUpdated(this.devices);
  @override
  List<Object?> get props => [devices];
}

class _ConnectionStatusChanged extends ConnectionEvent {
  final bool isConnected;
  const _ConnectionStatusChanged(this.isConnected);
  @override
  List<Object?> get props => [isConnected];
}

class _ScanStopped extends ConnectionEvent {
  const _ScanStopped();
}

class _ConnectError extends ConnectionEvent {
  final String message;
  const _ConnectError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── State ─────────────────────────────────────────────────────────────────────

class ConnectionState extends Equatable {
  final ConnectionType connectionType;
  final bool isScanning;
  final bool isConnecting;
  final bool isConnected;
  final List<BleDevice> discoveredDevices;
  final BleDevice? connectedDevice;
  final String? connectedWifiIp;
  final String? errorMessage;

  const ConnectionState({
    this.connectionType = ConnectionType.bluetooth,
    this.isScanning = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.connectedWifiIp,
    this.errorMessage,
  });

  ConnectionState copyWith({
    ConnectionType? connectionType,
    bool? isScanning,
    bool? isConnecting,
    bool? isConnected,
    List<BleDevice>? discoveredDevices,
    BleDevice? connectedDevice,
    String? connectedWifiIp,
    String? errorMessage,
    bool clearDevice = false,
    bool clearWifiIp = false,
    bool clearError = false,
  }) {
    return ConnectionState(
      connectionType: connectionType ?? this.connectionType,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice:
          clearDevice ? null : connectedDevice ?? this.connectedDevice,
      connectedWifiIp:
          clearWifiIp ? null : connectedWifiIp ?? this.connectedWifiIp,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        connectionType,
        isScanning,
        isConnecting,
        isConnected,
        discoveredDevices,
        connectedDevice,
        connectedWifiIp,
        errorMessage,
      ];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  StreamSubscription<BluetoothDiscoveryResult>? _scanSubscription;
  BluetoothConnection? _btConnection;
  BluetoothDevice? _activeDevice;
  Socket? _wifiSocket;
  Timer? _scanTimer;

  ConnectionBloc() : super(const ConnectionState()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ConnectToDevice>(_onConnect);
    on<DisconnectDevice>(_onDisconnect);
    on<SwitchConnectionType>(_onSwitchConnectionType);
    on<ConnectToWifi>(_onConnectToWifi);
    on<SendData>(_onSendData);
    on<_ScanResultsUpdated>(_onScanUpdated);
    on<_ConnectionStatusChanged>(_onConnectionStatusChanged);
    on<_ScanStopped>(_onScanStopped);
    on<_ConnectError>(_onConnectError);
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onStartScan(
      StartScan event, Emitter<ConnectionState> emit) async {
    // Request permissions first
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final denied =
        statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied);
    if (denied) {
      emit(state.copyWith(
          errorMessage: 'Bluetooth & Location permissions required.'));
      return;
    }

    // Check if Bluetooth is on
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (isEnabled == null || !isEnabled) {
      emit(state.copyWith(errorMessage: 'Please enable Bluetooth.'));
      return;
    }

    await _scanSubscription?.cancel();
    _scanTimer?.cancel();
    emit(state.copyWith(
      isScanning: true,
      discoveredDevices: [],
      clearError: true,
    ));

    // Get bonded devices first
    try {
      List<BluetoothDevice> bonded =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final bondedBle = bonded.map((d) {
        final name = (d.name != null && d.name!.isNotEmpty) ? d.name! : 'Unknown (${d.address})';
        return BleDevice(
          id: d.address,
          name: name,
          rawDevice: d,
        );
      }).toList();
      add(_ScanResultsUpdated(bondedBle));
    } catch (e) {
      // Ignore
    }

    // Subscribe to scan results stream
    _scanSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      final name = (r.device.name != null && r.device.name!.isNotEmpty) 
          ? r.device.name! 
          : 'Unknown (${r.device.address})';
      
      final newDevice = BleDevice(
        id: r.device.address,
        name: name,
        rssi: r.rssi,
        rawDevice: r.device,
      );
      add(_ScanResultsUpdated([newDevice]));
    }, onError: (error) {
      add(_ConnectError('Scan error: $error'));
    });

    // Start scan with 12-second timeout
    _scanTimer = Timer(const Duration(seconds: 12), () {
      add(const _ScanStopped());
    });
  }

  Future<void> _onStopScan(
      StopScan event, Emitter<ConnectionState> emit) async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    await _scanSubscription?.cancel();
    _scanTimer?.cancel();
    emit(state.copyWith(isScanning: false));
  }

  void _onScanStopped(_ScanStopped event, Emitter<ConnectionState> emit) {
    FlutterBluetoothSerial.instance.cancelDiscovery();
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    emit(state.copyWith(isScanning: false));
  }

  void _onScanUpdated(
      _ScanResultsUpdated event, Emitter<ConnectionState> emit) {
    // Deduplicate by device id
    final map = {for (final d in event.devices) d.id: d};
    final merged = {for (final d in state.discoveredDevices) d.id: d};
    merged.addAll(map);
    emit(state.copyWith(discoveredDevices: merged.values.toList()));
  }

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> _onConnect(
      ConnectToDevice event, Emitter<ConnectionState> emit) async {
    if (state.isScanning) {
      await FlutterBluetoothSerial.instance.cancelDiscovery();
      await _scanSubscription?.cancel();
      _scanTimer?.cancel();
    }

    // Disconnect any current device first
    await _btConnection?.close();
    _btConnection = null;
    _activeDevice = null;

    if (_wifiSocket != null) {
      _wifiSocket?.destroy();
      _wifiSocket = null;
    }

    emit(state.copyWith(
      isScanning: false,
      isConnecting: true,
      clearError: true,
      clearWifiIp: true,
    ));
    
    _activeDevice = event.device.rawDevice;

    try {
      _btConnection = await BluetoothConnection.toAddress(_activeDevice!.address);

      emit(state.copyWith(
        isConnecting: false,
        isConnected: true,
        connectedDevice: event.device,
        clearError: true,
      ));

      _btConnection!.input?.listen((data) {
        // Handle incoming data if needed
      }).onDone(() {
        add(const _ConnectionStatusChanged(false));
      });
      
    } catch (e) {
      emit(state.copyWith(
        isConnecting: false,
        isConnected: false,
        clearDevice: true,
        errorMessage: 'فشل الاتصال. تأكد من إقران (Pairing) الجهاز من إعدادات الموبايل أولاً وإدخال الـ PIN.',
      ));
    }
  }

  void _onConnectionStatusChanged(
      _ConnectionStatusChanged event, Emitter<ConnectionState> emit) {
    if (!event.isConnected) {
      emit(state.copyWith(
        isConnected: false,
        clearDevice: true,
      ));
    }
  }

  Future<void> _onDisconnect(
      DisconnectDevice event, Emitter<ConnectionState> emit) async {
    await _btConnection?.close();
    _btConnection = null;
    _activeDevice = null;

    if (_wifiSocket != null) {
      _wifiSocket?.destroy();
      _wifiSocket = null;
    }

    emit(state.copyWith(
        isConnected: false, clearDevice: true, clearWifiIp: true));
  }

  void _onSwitchConnectionType(
      SwitchConnectionType event, Emitter<ConnectionState> emit) {
    if (state.connectionType == event.type) return;

    if (state.isScanning) {
      FlutterBluetoothSerial.instance.cancelDiscovery();
      _scanSubscription?.cancel();
      _scanTimer?.cancel();
    }

    emit(state.copyWith(
      connectionType: event.type,
      isScanning: false,
      clearError: true,
    ));
  }

  Future<void> _onConnectToWifi(
      ConnectToWifi event, Emitter<ConnectionState> emit) async {
    await _btConnection?.close();
    _btConnection = null;
    _activeDevice = null;

    if (_wifiSocket != null) {
      _wifiSocket?.destroy();
      _wifiSocket = null;
    }

    emit(state.copyWith(
      isConnecting: true,
      clearError: true,
      clearDevice: true,
      clearWifiIp: true,
    ));

    try {
      _wifiSocket = await Socket.connect(event.ip, event.port,
          timeout: const Duration(seconds: 5));

      emit(state.copyWith(
        isConnecting: false,
        isConnected: true,
        connectedWifiIp: '${event.ip}:${event.port}',
        clearError: true,
      ));

      _wifiSocket?.listen(
        (data) {
          // Add data handling if required
        },
        onError: (error) {
          add(const DisconnectDevice());
          add(_ConnectError('WiFi Error: $error'));
        },
        onDone: () {
          add(const DisconnectDevice());
        },
        cancelOnError: true,
      );
    } catch (e) {
      emit(state.copyWith(
        isConnecting: false,
        isConnected: false,
        errorMessage: 'WiFi Connection failed. Check IP/Port and network.',
      ));
    }
  }

  Future<void> _onSendData(
      SendData event, Emitter<ConnectionState> emit) async {
    if (!state.isConnected) return;

    if (state.connectionType == ConnectionType.wifi && _wifiSocket != null) {
      try {
        _wifiSocket!.write(event.data);
      } catch (e) {
        // Ignore
      }
      return;
    }

    if (state.connectionType != ConnectionType.bluetooth ||
        _btConnection == null) {
      return;
    }

    try {
      _btConnection!.output
          .add(Uint8List.fromList(utf8.encode(event.data)));
      // Wait until the classic-SPP buffer is flushed for more reliable delivery.
      await _btConnection!.output.allSent;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Bluetooth send failed — check link. ($e)',
      ));
    }
  }

  void _onConnectError(_ConnectError event, Emitter<ConnectionState> emit) {
    emit(state.copyWith(
      isConnecting: false,
      isConnected: false,
      errorMessage: event.message,
    ));
  }

  @override
  Future<void> close() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    await _scanSubscription?.cancel();
    await _btConnection?.close();
    _scanTimer?.cancel();
    _wifiSocket?.destroy();
    return super.close();
  }
}
