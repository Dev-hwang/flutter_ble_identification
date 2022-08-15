import 'package:flutter_ble_identification/models/ble_scan_mode.dart';

class BleScannerOptions {
  const BleScannerOptions({
    this.deviceAddressFilters = const [],
    this.deviceNameFilters = const [],
    this.serviceUuidFilters = const [],
    this.scanMode = BleScanMode.SCAN_MODE_LOW_POWER,
    this.reportDelay = 0,
  });

  final List<String> deviceAddressFilters;
  final List<String> deviceNameFilters;
  final List<String> serviceUuidFilters;
  final BleScanMode scanMode;
  final int reportDelay;

  Map<String, dynamic> toJson() {
    return {
      'deviceAddressFilters': deviceAddressFilters,
      'deviceNameFilters': deviceNameFilters,
      'serviceUuidFilters': serviceUuidFilters,
      'scanMode': scanMode.rawValue,
      'reportDelay': reportDelay,
    };
  }
}
