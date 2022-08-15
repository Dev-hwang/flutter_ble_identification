import 'package:flutter_dev_framework/utils/date_time_utils.dart';

enum LogType {
  SUCCESS,
  INFO,
  ERROR,
}

class LogData {
  const LogData({
    required this.type,
    required this.message,
    required this.timestamp,
  });

  final LogType type;
  final String message;
  final String timestamp;

  factory LogData.success(String message) {
    return LogData(
      type: LogType.SUCCESS,
      message: message,
      timestamp: DateTimeUtils.instance.getNowDateTimeString(),
    );
  }

  factory LogData.info(String message) {
    return LogData(
      type: LogType.INFO,
      message: message,
      timestamp: DateTimeUtils.instance.getNowDateTimeString(),
    );
  }

  factory LogData.error(String message) {
    return LogData(
      type: LogType.ERROR,
      message: message,
      timestamp: DateTimeUtils.instance.getNowDateTimeString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
