enum ServiceErrorCodes {
  SCAN_FAILED_ALREADY_STARTED,
  SCAN_FAILED_APPLICATION_REGISTRATION_FAILED,
  SCAN_FAILED_FEATURE_UNSUPPORTED,
  SCAN_FAILED_INTERNAL_ERROR,
  WRITE_CHARACTERISTIC_FAILED,
  READ_CHARACTERISTIC_FAILED,
  ACCESS_USER_TIMEOUT,
  ACCESS_USER_FAILED,
  UNKNOWN_ERROR,
}

ServiceErrorCodes getServiceErrorCodesFromValue(dynamic value) =>
    ServiceErrorCodes.values.firstWhere(
      (e) =>
          e.toString() == value.toString() ||
          e.toString() == 'ServiceErrorCodes.${value.toString()}',
      orElse: () => ServiceErrorCodes.UNKNOWN_ERROR,
    );
