import 'package:flutter_ble_identification/errors/service_error_codes.dart';

class ServiceError {
  const ServiceError({required this.errorCode, required this.errorMessage});

  final ServiceErrorCodes errorCode;
  final String errorMessage;

  factory ServiceError.fromJson(Map<String, dynamic> json) {
    final errorCode = getServiceErrorCodesFromValue(json['errorCode']);
    final errorMessage = json['errorMessage'].toString();

    return ServiceError(errorCode: errorCode, errorMessage: errorMessage);
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'errorMessage': errorMessage,
    };
  }
}
