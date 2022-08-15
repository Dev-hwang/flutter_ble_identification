class NotificationButton {
  const NotificationButton({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}
