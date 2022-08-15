//
//  BleIdentificationServiceCallback.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

protocol BleIdentificationServiceCallback {
  func onAccessSuccess(resultCode: String)
  func onAccessFailure(resultCode: String)
  func onScanError(errorJson: String)
  func onGattError(errorJson: String)
  func onGattInfo(message: String)
}
