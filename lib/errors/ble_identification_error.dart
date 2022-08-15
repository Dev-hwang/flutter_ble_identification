class BleIdentificationError implements Exception {
  final String? _message;

  const BleIdentificationError([this._message]);

  @override
  String toString() => _message ?? 'BleIdentificationError';
}
