//
//  ServiceError.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

struct ServiceError: Codable {
  let errorCode: String
  let errorMessage: String
  
  init(errorCode: String, errorMessage: String) {
    self.errorCode = errorCode
    self.errorMessage = errorMessage
  }
}
