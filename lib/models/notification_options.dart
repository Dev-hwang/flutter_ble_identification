import 'package:flutter_ble_identification/models/notification_button.dart';
import 'package:flutter_ble_identification/models/notification_channel_importance.dart';
import 'package:flutter_ble_identification/models/notification_icon_data.dart';
import 'package:flutter_ble_identification/models/notification_priority.dart';
import 'package:flutter_ble_identification/models/notification_visibility.dart';

class NotificationOptions {
  const NotificationOptions({
    required this.channelId,
    required this.channelName,
    this.channelDescription,
    this.channelImportance = NotificationChannelImportance.DEFAULT,
    this.priority = NotificationPriority.DEFAULT,
    this.enableVibration = false,
    this.playSound = false,
    this.showWhen = false,
    this.isSticky = true,
    this.visibility = NotificationVisibility.VISIBILITY_PUBLIC,
    this.iconData,
    this.buttons,
  }) : assert((buttons?.length ?? 0) < 4);

  final String channelId;
  final String channelName;
  final String? channelDescription;
  final NotificationChannelImportance channelImportance;
  final NotificationPriority priority;
  final bool enableVibration;
  final bool playSound;
  final bool showWhen;
  final bool isSticky;
  final NotificationVisibility visibility;
  final NotificationIconData? iconData;
  final List<NotificationButton>? buttons;

  Map<String, dynamic> toJson() {
    return {
      'notificationChannelId': channelId,
      'notificationChannelName': channelName,
      'notificationChannelDescription': channelDescription,
      'notificationChannelImportance': channelImportance.rawValue,
      'notificationPriority': priority.rawValue,
      'enableVibration': enableVibration,
      'playSound': playSound,
      'showWhen': showWhen,
      'isSticky': isSticky,
      'visibility': visibility.rawValue,
      'iconData': iconData?.toJson(),
      'buttons': buttons?.map((e) => e.toJson()).toList(),
    };
  }
}
