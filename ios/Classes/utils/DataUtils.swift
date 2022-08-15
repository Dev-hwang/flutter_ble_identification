//
//  BytesUtils.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/10.
//

import Foundation

class DataUtils {
  static func dataToHexString(input: Data, separator: String = "") -> String {
    return input.map { String(format: "%02hhx", $0) }.joined(separator: separator)
  }
}
