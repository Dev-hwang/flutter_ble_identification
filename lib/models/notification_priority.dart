class NotificationPriority {
  const NotificationPriority(this.rawValue);

  static const NotificationPriority MIN = NotificationPriority(-2);
  static const NotificationPriority LOW = NotificationPriority(-1);
  static const NotificationPriority DEFAULT = NotificationPriority(0);
  static const NotificationPriority HIGH = NotificationPriority(1);
  static const NotificationPriority MAX = NotificationPriority(2);

  final int rawValue;
}
