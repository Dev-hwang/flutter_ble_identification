//
//  AccessResult.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/10.
//

import Foundation

struct AccessResult: Codable {
  let resultCode: String
  let resultMessage: String
  
  init(resultCode: String, resultMessage: String) {
    self.resultCode = resultCode
    self.resultMessage = resultMessage
  }
}
