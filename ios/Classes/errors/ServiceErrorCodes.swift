//
//  ServiceErrorCodes.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

enum ServiceErrorCodes: String {
  case SCAN_FAILED_ALREADY_STARTED
  case SCAN_FAILED_APPLICATION_REGISTRATION_FAILED
  case SCAN_FAILED_FEATURE_UNSUPPORTED
  case SCAN_FAILED_INTERNAL_ERROR
  case WRITE_CHARACTERISTIC_FAILED
  case READ_CHARACTERISTIC_FAILED
  case ACCESS_USER_TIMEOUT
  case ACCESS_USER_FAILED
  case UNKNOWN_ERROR
  
  func message() -> String {
    switch self {
      case .SCAN_FAILED_ALREADY_STARTED:
        return "Fails to start scan as BLE scan with the same settings is already started by the app."
      case .SCAN_FAILED_APPLICATION_REGISTRATION_FAILED:
        return "Fails to start scan as app cannot be registered."
      case .SCAN_FAILED_FEATURE_UNSUPPORTED:
        return "Fails to start power optimized scan as this feature is not supported."
      case .SCAN_FAILED_INTERNAL_ERROR:
        return "Fails to start scan due an internal error."
      case .WRITE_CHARACTERISTIC_FAILED:
        return "Fails to write characteristic."
      case .READ_CHARACTERISTIC_FAILED:
        return "Fails to read characteristic."
      case .ACCESS_USER_TIMEOUT:
        return "출입 인증 요청 응답시간이 초과되었습니다."
      case .ACCESS_USER_FAILED:
        return "출입 인증 요청에 실패하였습니다."
      case .UNKNOWN_ERROR:
        return "An unknown error has occurred."
    }
  }
  
  func toModel(errorMessage: String? = nil) -> ServiceError {
    return ServiceError(
      errorCode: self.rawValue,
      errorMessage: errorMessage ?? self.message()
    )
  }
}
