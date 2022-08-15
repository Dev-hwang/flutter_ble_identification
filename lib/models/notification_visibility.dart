class NotificationVisibility {
  const NotificationVisibility(this.rawValue);

  static const NotificationVisibility VISIBILITY_PUBLIC =
      NotificationVisibility(1);
  static const NotificationVisibility VISIBILITY_SECRET =
      NotificationVisibility(-1);
  static const NotificationVisibility VISIBILITY_PRIVATE =
      NotificationVisibility(0);

  final int rawValue;
}
