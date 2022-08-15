enum ResourceType {
  drawable,
  mipmap,
}

enum ResourcePrefix {
  ic,
  img,
}

class NotificationIconData {
  const NotificationIconData({
    required this.resType,
    required this.resPrefix,
    required this.name,
  });

  final ResourceType resType;
  final ResourcePrefix resPrefix;
  final String name;

  Map<String, String> toJson() {
    return {
      'resType': resType.toString().split('.').last,
      'resPrefix': resPrefix.toString().split('.').last,
      'name': name,
    };
  }
}
