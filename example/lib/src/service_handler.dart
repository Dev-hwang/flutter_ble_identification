import 'dart:async';
import 'dart:isolate';

import 'package:flutter_ble_identification/flutter_ble_identification.dart';

void startBleIdentificationServiceHandler() =>
    FlutterBleIdentification.setServiceHandler(BleIdentificationServiceHandler());

class BleIdentificationServiceHandler extends ServiceHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {

  }

  @override
  Future<void> onAccessSuccess(DateTime timestamp, SendPort? sendPort, AccessResult result) async {
    print('onAccessSuccess: ${result.toJson()}');
    sendPort?.send(result);
  }

  @override
  Future<void> onAccessFailure(DateTime timestamp, SendPort? sendPort, AccessResult result) async {
    print('onAccessFailure: ${result.toJson()}');
    sendPort?.send(result);
  }

  @override
  Future<void> onScanError(DateTime timestamp, SendPort? sendPort, ServiceError error) async {
    print('onScanError: ${error.toJson()}');
    sendPort?.send(error);
  }

  @override
  Future<void> onGattError(DateTime timestamp, SendPort? sendPort, ServiceError error) async {
    print('onGattError: ${error.toJson()}');
    sendPort?.send(error);
  }

  @override
  Future<void> onGattInfo(DateTime timestamp, SendPort? sendPort, String message) async {
    print('onGattInfo: $message');
    sendPort?.send(message);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {

  }
}
