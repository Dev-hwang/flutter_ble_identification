class ForegroundServiceOptions {
  const ForegroundServiceOptions({
    this.autoRunOnBoot = false,
    this.allowWifiLock = false,
  });

  final bool autoRunOnBoot;
  final bool allowWifiLock;

  Map<String, dynamic> toJson() {
    return {
      'autoRunOnBoot': autoRunOnBoot,
      'allowWifiLock': allowWifiLock,
    };
  }
}
