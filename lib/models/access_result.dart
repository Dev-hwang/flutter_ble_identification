import 'package:flutter_ble_identification/models/access_result_codes.dart';

class AccessResult {
  const AccessResult({required this.resultCode, required this.resultMessage});

  final AccessResultCodes resultCode;
  final String resultMessage;

  factory AccessResult.fromJson(Map<String, dynamic> json) {
    final resultCode = getAccessResultCodesFromValue(json['resultCode']);
    final resultMessage = json['resultMessage'].toString();

    return AccessResult(resultCode: resultCode, resultMessage: resultMessage);
  }

  Map<String, dynamic> toJson() {
    return {
      'resultCode': resultCode,
      'resultMessage': resultMessage,
    };
  }
}
