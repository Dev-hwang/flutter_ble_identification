import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_identification/errors/ble_identification_error.dart';
import 'package:flutter_ble_identification/errors/service_error.dart';
import 'package:flutter_ble_identification/models/access_result.dart';
import 'package:flutter_ble_identification/models/ble_scanner_options.dart';
import 'package:flutter_ble_identification/models/foreground_service_options.dart';
import 'package:flutter_ble_identification/models/notification_options.dart';

export 'package:flutter_ble_identification/errors/ble_identification_error.dart';
export 'package:flutter_ble_identification/errors/service_error.dart';
export 'package:flutter_ble_identification/errors/service_error_codes.dart';
export 'package:flutter_ble_identification/models/access_result.dart';
export 'package:flutter_ble_identification/models/access_result_codes.dart';
export 'package:flutter_ble_identification/models/ble_scan_mode.dart';
export 'package:flutter_ble_identification/models/ble_scanner_options.dart';
export 'package:flutter_ble_identification/models/foreground_service_options.dart';
export 'package:flutter_ble_identification/models/notification_button.dart';
export 'package:flutter_ble_identification/models/notification_channel_importance.dart';
export 'package:flutter_ble_identification/models/notification_icon_data.dart';
export 'package:flutter_ble_identification/models/notification_options.dart';
export 'package:flutter_ble_identification/models/notification_priority.dart';
export 'package:flutter_ble_identification/models/notification_visibility.dart';

const String _kPortName = 'flutter_ble_identification/isolateComPort';

abstract class ServiceHandler {
  Future<void> onStart(DateTime timestamp, SendPort? sendPort);

  Future<void> onAccessSuccess(
      DateTime timestamp, SendPort? sendPort, AccessResult result);

  Future<void> onAccessFailure(
      DateTime timestamp, SendPort? sendPort, AccessResult result);

  Future<void> onScanError(
      DateTime timestamp, SendPort? sendPort, ServiceError error);

  Future<void> onGattError(
      DateTime timestamp, SendPort? sendPort, ServiceError error);

  Future<void> onGattInfo(
      DateTime timestamp, SendPort? sendPort, String message);

  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort);

  void onButtonPressed(String id) {}
}

class FlutterBleIdentification {
  static const _mChannel = MethodChannel('flutter_ble_identification/method');

  static NotificationOptions? _notificationOptions;
  static ForegroundServiceOptions? _foregroundServiceOptions;
  static BleScannerOptions? _bleScannerOptions;
  static bool _printDevLog = false;

  static Future<void> init({
    required NotificationOptions notificationOptions,
    ForegroundServiceOptions? foregroundServiceOptions,
    BleScannerOptions? bleScannerOptions,
    bool? printDevLog,
  }) async {
    _notificationOptions = notificationOptions;
    _foregroundServiceOptions = foregroundServiceOptions ??
        _foregroundServiceOptions ??
        const ForegroundServiceOptions();
    _bleScannerOptions =
        bleScannerOptions ?? _bleScannerOptions ?? const BleScannerOptions();
    _printDevLog = printDevLog ?? _printDevLog;
    _printMessage('FlutterBleIdentification has been initialized.');
  }

  static Future<ReceivePort?> startService({
    required String notificationTitle,
    required String notificationText,
    required String authKey,
    Function? callback,
  }) async {
    if (await isRunningService) {
      throw const BleIdentificationError(
          'Already started. Please call this function after calling the stop function.');
    }

    if (_foregroundServiceOptions == null) {
      throw const BleIdentificationError(
          'Not initialized. Please call this function after calling the init function.');
    }

    final receivePort = _registerPort();
    if (receivePort == null) {
      throw const BleIdentificationError(
          'Failed to register SendPort to communicate with background isolate.');
    }

    final options = _notificationOptions?.toJson() ?? <String, dynamic>{};
    options['notificationContentTitle'] = notificationTitle;
    options['notificationContentText'] = notificationText;
    options['authKey'] = authKey;
    if (callback != null) {
      options.addAll(_foregroundServiceOptions!.toJson());
      options.addAll(_bleScannerOptions!.toJson());
      options['callbackHandle'] =
          PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
    }

    final bool result =
        await _mChannel.invokeMethod('startForegroundService', options);
    if (result) {
      _printMessage('FlutterBleIdentification has been requested to start.');
      return receivePort;
    }

    return null;
  }

  static Future<ReceivePort?> restartService() async {
    if (!await isRunningService) {
      throw const BleIdentificationError(
          'There are no service started or running.');
    }

    final receivePort = _registerPort();
    if (receivePort == null) {
      throw const BleIdentificationError(
          'Failed to register SendPort to communicate with background isolate.');
    }

    final bool result =
        await _mChannel.invokeMethod('restartForegroundService');
    if (result) {
      _printMessage('FlutterBleIdentification has been requested to restart.');
      return receivePort;
    }

    return null;
  }

  static Future<bool> updateService({
    String? notificationTitle,
    String? notificationText,
    String? authKey,
    Function? callback,
  }) async {
    // If the service is not running, the update function is not executed.
    if (!await isRunningService) return false;

    final options = <String, dynamic>{};
    options['notificationContentTitle'] = notificationTitle;
    options['notificationContentText'] = notificationText;
    options['authKey'] = authKey;
    if (callback != null) {
      options['callbackHandle'] =
          PluginUtilities.getCallbackHandle(callback)?.toRawHandle();
    }

    final bool result =
        await _mChannel.invokeMethod('updateForegroundService', options);
    if (result) {
      _printMessage('FlutterBleIdentification has been requested to update.');
      return true;
    }

    return false;
  }

  static Future<bool> stopService() async {
    // If the service is not running, the stop function is not executed.
    if (!await isRunningService) return false;

    final bool result = await _mChannel.invokeMethod('stopForegroundService');
    if (result) {
      _printMessage('FlutterBleIdentification has been requested to stop.');
      return true;
    }

    return false;
  }

  static Future<bool> get isRunningService async {
    return await _mChannel.invokeMethod('isRunningService');
  }

  static Future<bool> get isSupportedBle async {
    return await _mChannel.invokeMethod('isSupportedBle');
  }

  static Future<bool> get isSupportedBt async {
    return await _mChannel.invokeMethod('isSupportedBt');
  }

  static Future<bool> get isEnabledBt async {
    return await _mChannel.invokeMethod('isEnabledBt');
  }

  static Future<bool> requestEnableBt() async {
    return await _mChannel.invokeMethod('requestEnableBt');
  }

  static Future<bool> get isIgnoringBatteryOptimizations async {
    // This function only works on Android.
    if (!Platform.isAndroid) return true;

    return await _mChannel.invokeMethod('isIgnoringBatteryOptimizations');
  }

  static Future<bool> requestIgnoreBatteryOptimization() async {
    // This function only works on Android.
    if (!Platform.isAndroid) return true;

    return await _mChannel.invokeMethod('requestIgnoreBatteryOptimization');
  }

  static void setServiceHandler(ServiceHandler handler) {
    // Create a method channel to communicate with the platform.
    const _backgroundChannel =
        MethodChannel('flutter_ble_identification/background');

    // Binding the framework to the flutter engine.
    WidgetsFlutterBinding.ensureInitialized();

    // Set the method call handler for the background channel.
    _backgroundChannel.setMethodCallHandler((call) async {
      final timestamp = DateTime.now();
      final sendPort = _lookupPort();

      switch (call.method) {
        case 'onStart':
          await handler.onStart(timestamp, sendPort);
          break;
        case 'onAccessSuccess':
          final result = AccessResult.fromJson(jsonDecode(call.arguments));
          await handler.onAccessSuccess(timestamp, sendPort, result);
          break;
        case 'onAccessFailure':
          final result = AccessResult.fromJson(jsonDecode(call.arguments));
          await handler.onAccessFailure(timestamp, sendPort, result);
          break;
        case 'onScanError':
          final error = ServiceError.fromJson(jsonDecode(call.arguments));
          await handler.onScanError(timestamp, sendPort, error);
          break;
        case 'onGattError':
          final error = ServiceError.fromJson(jsonDecode(call.arguments));
          await handler.onGattError(timestamp, sendPort, error);
          break;
        case 'onGattInfo':
          final message = call.arguments;
          await handler.onGattInfo(timestamp, sendPort, message);
          break;
        case 'onDestroy':
          await handler.onDestroy(timestamp, sendPort);
          _removePort();
          break;
        case 'onButtonPressed':
          handler.onButtonPressed(call.arguments.toString());
      }
    });

    // Initializes the plug-in background channel.
    _backgroundChannel.invokeMethod('startBackgroundService');
  }

  static Future<ReceivePort?> get receivePort async {
    if (!await isRunningService) return null;

    return _registerPort();
  }

  static ReceivePort? _registerPort() {
    if (_removePort()) {
      final receivePort = ReceivePort();
      final sendPort = receivePort.sendPort;
      if (IsolateNameServer.registerPortWithName(sendPort, _kPortName)) {
        return receivePort;
      }
    }

    return null;
  }

  static SendPort? _lookupPort() {
    return IsolateNameServer.lookupPortByName(_kPortName);
  }

  static bool _removePort() {
    if (_lookupPort() != null) {
      return IsolateNameServer.removePortNameMapping(_kPortName);
    }

    return true;
  }

  static void _printMessage(String message) {
    if (kReleaseMode || _printDevLog == false) return;

    final nowDateTime = DateTime.now().toString();
    dev.log('$nowDateTime\t$message');
  }
}
