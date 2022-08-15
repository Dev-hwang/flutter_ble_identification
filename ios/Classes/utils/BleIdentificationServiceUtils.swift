//
//  BleIdentificationServiceUtils.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/13.
//

import Foundation

let PACKET_MINIMUM_LENGTH = 8
let PACKET_HEADER_AREA_LENGTH = 5
let PACKET_INT_VALUE: UInt8 = 0x00
let PACKET_STX_VALUE: UInt8 = 0x02
let PACKET_ETX_VALUE: UInt8 = 0x03

class BleIdentificationServiceUtils {
  static func generateUserAccessPacket(authKey: String) -> [UInt8] {
    let data: [UInt8]
    let hexAuthKey = String(Int(authKey) ?? 0, radix: 16, uppercase: true)
    let hexAuthKeyCount = hexAuthKey.count
    if hexAuthKeyCount < 8 {
      let zeroPaddingCount = 8 - hexAuthKeyCount
      var zeroPadding = ""
      for _ in 1...zeroPaddingCount {
        zeroPadding += "0"
      }
      data = Array((zeroPadding + hexAuthKey).utf8)
    } else {
      data = Array(hexAuthKey.utf8)
    }
    
    return generateCommandPacket(command: 0x50, data: data, encryptData: false)
  }
  
  static func generateCommandPacket(command: UInt8, data: [UInt8], encryptData: Bool = true) -> [UInt8] {
    let dataArea: [UInt8]
    if !data.isEmpty && encryptData {
      // TODO: 암호화 통신 방식 확인 필요
      dataArea = data
    } else {
      dataArea = data
    }
    
    var headerArea = [UInt8](repeating: PACKET_INT_VALUE, count: PACKET_HEADER_AREA_LENGTH)
    headerArea[0] = PACKET_STX_VALUE
    write2BytesToBuffer(buffer: &headerArea, offset: 1, input: PACKET_MINIMUM_LENGTH + dataArea.count)
    headerArea[3] = PACKET_INT_VALUE
    headerArea[4] = command
    
    let checkArea = headerArea + dataArea + [PACKET_ETX_VALUE]
    let crcCode = generate2BytesCrcCode(input: checkArea)
    
    return checkArea + crcCode
  }
  
  static func generate2BytesCrcCode(input: [UInt8]) -> [UInt8] {
    var crcCode = [UInt8](repeating: PACKET_INT_VALUE, count: 2)
    let crc16 = CRC16()
    crc16.update(arr: input)
    write2BytesToBuffer(buffer: &crcCode, offset: 0, input: crc16.getValue())
    
    return crcCode
  }
  
  static func write2BytesToBuffer(buffer: inout [UInt8], offset: Int, input: Int) {
    buffer[offset + 0] = UInt8(truncatingIfNeeded: input >> 0)
    buffer[offset + 1] = UInt8(truncatingIfNeeded: input >> 8)
  }
}
