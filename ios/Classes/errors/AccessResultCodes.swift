//
//  AccessResultCodes.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/10.
//

import Foundation

enum AccessResultCodes: String {
  case COMM_SUCCESS
  case COMM_WRONG_CRC
  case COMM_INVALID_COMMAND
  case COMM_WRONG_LENGTH
  case COMM_WRITE_FAIL
  case COMM_WRONG_DATA
  case COMM_FLOW_ERROR
  case COMM_ADMIN_MODE_FAIL
  case COMM_ADMIN_AUTH_FAIL
  case COMM_AUTH_FAIL
  case COMM_AUTH_METHOD_FAIL
  case UNKNOWN
  
  func message() -> String {
    switch self {
      case .COMM_SUCCESS:
        return "명령어가 성공적으로 수행되었음"
      case .COMM_WRONG_CRC:
        return "명령패킷의 CRC 값이 맞지 않음"
      case .COMM_INVALID_COMMAND:
        return "명령이 존재하지 않음"
      case .COMM_WRONG_LENGTH:
        return "명령패킷의 Data 사이즈가 맞지 않음"
      case .COMM_WRITE_FAIL:
        return "메모리에 쓰기 실패"
      case .COMM_WRONG_DATA:
        return "명령패킷의 Data 구성이 잘못됨"
      case .COMM_FLOW_ERROR:
        return "메모리 쓰기 순서가 맞지 않음"
      case .COMM_ADMIN_MODE_FAIL:
        return "관리자 모드가 아님"
      case .COMM_ADMIN_AUTH_FAIL:
        return "관리자 인증 실패"
      case .COMM_AUTH_FAIL:
        return "MAC 인증 실패"
      case .COMM_AUTH_METHOD_FAIL:
        return "사용자 인증 방법이 맞지 않음"
      case .UNKNOWN:
        return "알 수 없는 코드임"
    }
  }
  
  func toModel(resultMessage: String? = nil) -> AccessResult {
    return AccessResult(
      resultCode: self.rawValue,
      resultMessage: resultMessage ?? self.message()
    )
  }
  
  static func fromByte(byte: UInt8) -> AccessResultCodes {
    switch DataUtils.dataToHexString(input: Data([byte])) {
      case "00":
        return .COMM_SUCCESS
      case "01":
        return .COMM_WRONG_CRC
      case "02":
        return .COMM_INVALID_COMMAND
      case "03":
        return .COMM_WRONG_LENGTH
      case "04":
        return .COMM_WRITE_FAIL
      case "05":
        return .COMM_WRONG_DATA
      case "06":
        return .COMM_FLOW_ERROR
      case "0A":
        return .COMM_ADMIN_MODE_FAIL
      case "0B":
        return .COMM_ADMIN_AUTH_FAIL
      case "0D":
        return .COMM_AUTH_FAIL
      case "0F":
        return .COMM_AUTH_METHOD_FAIL
      default:
        return .UNKNOWN
    }
  }
}
