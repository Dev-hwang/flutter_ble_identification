enum AccessResultCodes {
  COMM_SUCCESS,
  COMM_WRONG_CRC,
  COMM_INVALID_COMMAND,
  COMM_WRONG_LENGTH,
  COMM_WRITE_FAIL,
  COMM_WRONG_DATA,
  COMM_FLOW_ERROR,
  COMM_ADMIN_MODE_FAIL,
  COMM_ADMIN_AUTH_FAIL,
  COMM_AUTH_FAIL,
  COMM_AUTH_METHOD_FAIL,
  UNKNOWN,
}

AccessResultCodes getAccessResultCodesFromValue(dynamic value) =>
    AccessResultCodes.values.firstWhere(
      (e) =>
          e.toString() == value.toString() ||
          e.toString() == 'AccessResultCodes.${value.toString()}',
      orElse: () => AccessResultCodes.UNKNOWN,
    );
