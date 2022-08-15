class BleScanMode {
  const BleScanMode(this.rawValue);

  static const BleScanMode SCAN_MODE_BALANCED = BleScanMode(1);
  static const BleScanMode SCAN_MODE_LOW_LATENCY = BleScanMode(2);
  static const BleScanMode SCAN_MODE_LOW_POWER = BleScanMode(0);
  static const BleScanMode SCAN_MODE_OPPORTUNISTIC = BleScanMode(-1);

  final int rawValue;
}
