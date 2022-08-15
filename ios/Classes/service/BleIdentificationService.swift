//
//  BleIdentificationService.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import CoreBluetooth
import Foundation

let UART_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
let RX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
let TX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

let BLE_SCANNER_RESTART_INTERVAL = 10 // 10초
let PERIPHERAL_SESSION_TIMEOUT = 3    // 3초

class BleIdentificationService: NSObject {
  var callback: BleIdentificationServiceCallback? = nil
  var bleScannerOptions: BleScannerOptions? = nil
  var bleIdentificationData: BleIdentificationData? = nil
  
  var centralManager: CBCentralManager? = nil
  var peripheralDict: [String : CBPeripheral] = [:]
  var rxCharacteristicDict: [String : CBCharacteristic] = [:]
  var txCharacteristicDict: [String : CBCharacteristic] = [:]
  var peripheralSessionTimeoutWorkDict: [String : DispatchWorkItem] = [:]
  
  var scanStartWork: DispatchWorkItem? = nil
  var scanStoppedTimeNanos: UInt64 = 0
  
  let jsonEncoder = JSONEncoder()
  
  func start(callback: BleIdentificationServiceCallback) {
    self.callback = callback
    bleScannerOptions = BleScannerOptions.getData()
    bleIdentificationData = BleIdentificationData.getData()
    
    centralManager = CBCentralManager(
      delegate: self,
      queue: nil,
      options: [CBCentralManagerOptionShowPowerAlertKey: true]
    )
  }
  
  func stop() {
    stopScan()
    
    for timeoutWork in peripheralSessionTimeoutWorkDict.values {
      timeoutWork.cancel()
    }
    for peripheral in peripheralDict.values {
      centralManager?.cancelPeripheralConnection(peripheral)
    }
    peripheralDict.removeAll()
    rxCharacteristicDict.removeAll()
    txCharacteristicDict.removeAll()
    peripheralSessionTimeoutWorkDict.removeAll()
    centralManager = nil
    
    callback = nil
    bleScannerOptions = nil
    bleIdentificationData = nil
  }
  
  private func startScan() {
    stopScan()
    
    let currTimeNanos = DispatchTime.now().uptimeNanoseconds
    let diffTimeNanos = currTimeNanos - scanStoppedTimeNanos
    let diffTimeSeconds = Int(diffTimeNanos) / 1_000_000_000
    
    let workDelay: UInt32
    if scanStoppedTimeNanos == 0 || diffTimeSeconds >= BLE_SCANNER_RESTART_INTERVAL {
      workDelay = UInt32(0)
    } else {
      workDelay = UInt32(BLE_SCANNER_RESTART_INTERVAL - diffTimeSeconds)
    }
    
    scanStartWork = DispatchWorkItem {
      sleep(workDelay)
      
      if self.scanStartWork?.isCancelled ?? true {
        return
      }
      
      var serviceUuids: [CBUUID] = []
      for serviceUuid in self.bleScannerOptions?.serviceUuidFilters ?? [] {
        serviceUuids.append(CBUUID(string: serviceUuid))
      }
      
      self.centralManager?.scanForPeripherals(
        withServices: serviceUuids,
        options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
      )
    }
    
    DispatchQueue.global(qos: .userInitiated).async(execute: scanStartWork!)
  }
  
  private func stopScan() {
    if centralManager?.isScanning == true {
      centralManager?.stopScan()
      scanStoppedTimeNanos = DispatchTime.now().uptimeNanoseconds
    }
    
    scanStartWork?.cancel()
    scanStartWork = nil
  }
  
  private func connectPeripheral(_ peripheral: CBPeripheral) {
    stopScan()
    
    // 서비스 탐색 및 데이터 송수신을 위한 대리자 등록
    peripheral.delegate = self
    
    centralManager?.connect(peripheral)
    
    let strUUID = peripheral.identifier.uuidString
    peripheralDict[strUUID] = peripheral
  }
  
  private func disconnetPeripheral(_ peripheral: CBPeripheral) {
    centralManager?.cancelPeripheralConnection(peripheral)
    
    let strUUID = peripheral.identifier.uuidString
    if peripheralDict[strUUID] != nil {
      peripheralDict.removeValue(forKey: strUUID)
      rxCharacteristicDict.removeValue(forKey: strUUID)
      txCharacteristicDict.removeValue(forKey: strUUID)
      peripheralSessionTimeoutWorkDict[strUUID]?.cancel()
      peripheralSessionTimeoutWorkDict.removeValue(forKey: strUUID)
      
      if peripheralDict.isEmpty {
        startScan()
      }
    }
  }
  
  private func onAccessResult(result: AccessResult) {
    do {
      guard let resultJson = String(data: try jsonEncoder.encode(result), encoding: .utf8) else { return }
      if AccessResultCodes.init(rawValue: result.resultCode) == AccessResultCodes.COMM_SUCCESS {
        callback?.onAccessSuccess(resultCode: resultJson)
      } else {
        callback?.onAccessFailure(resultCode: resultJson)
      }
    } catch {
      
    }
  }
  
  private func onScanError(error: ServiceError) {
    do {
      guard let errorJson = String(data: try jsonEncoder.encode(error), encoding: .utf8) else { return }
      callback?.onScanError(errorJson: errorJson)
    } catch {
      
    }
  }
  
  private func onGattError(error: ServiceError) {
    do {
      guard let errorJson = String(data: try jsonEncoder.encode(error), encoding: .utf8) else { return }
      callback?.onGattError(errorJson: errorJson)
    } catch {
      
    }
  }
  
  private func onGattInfo(message: String) {
    callback?.onGattInfo(message: message)
  }
}

extension BleIdentificationService: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
      case .unknown:
        onScanError(error: ServiceErrorCodes.SCAN_FAILED_INTERNAL_ERROR.toModel())
      case .resetting:
        onScanError(error: ServiceErrorCodes.SCAN_FAILED_INTERNAL_ERROR.toModel())
      case .unsupported:
        onScanError(error: ServiceErrorCodes.SCAN_FAILED_FEATURE_UNSUPPORTED.toModel())
      case .unauthorized:
        onScanError(error: ServiceErrorCodes.SCAN_FAILED_APPLICATION_REGISTRATION_FAILED.toModel())
      case .poweredOff:
        onGattInfo(message: "블루투스가 꺼져있어 장치를 스캔할 수 없습니다.")
      case .poweredOn:
        startScan()
      @unknown default:
        onScanError(error: ServiceErrorCodes.SCAN_FAILED_INTERNAL_ERROR.toModel())
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    let strUUID = peripheral.identifier.uuidString
    let intRSSI = RSSI.intValue
    
    // 디바이스에 연결 요청 중이거나 BLE 통신 중인 경우
    if peripheralDict.keys.contains(strUUID) {
      return
    }
    
    // 수신 감도가 -55dBm 보다 나쁜 경우
    if intRSSI > 0 || intRSSI < -55 {
      onGattInfo(message: "[\(strUUID)] Bad RSSI: \(intRSSI)")
      return
    }
    
    connectPeripheral(peripheral)
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    disconnetPeripheral(peripheral)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    let strUUID = peripheral.identifier.uuidString
    onGattInfo(message: "[\(strUUID)] 출입 인증 장치와 연결되었습니다.")
    peripheral.discoverServices([CBUUID(string: UART_UUID)])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    onGattInfo(message: "[\(strUUID)] 출입 인증 장치와 연결이 끊어졌습니다.")
    disconnetPeripheral(peripheral)
  }
}

extension BleIdentificationService: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    
    if let error = error {
      onGattInfo(message: "[\(strUUID)] Nordic UART 서비스를 찾는 중 오류가 발생하였습니다. error: \(error)")
      disconnetPeripheral(peripheral)
      return
    }
    
    guard let services = peripheral.services else {
      onGattInfo(message: "[\(strUUID)] Nordic UART 서비스를 찾을 수 없습니다.")
      disconnetPeripheral(peripheral)
      return
    }
    
    onGattInfo(message: "[\(strUUID)] Nordic UART 서비스를 발견하였습니다.")
    for service in services {
      peripheral.discoverCharacteristics(
        [
          CBUUID(string: RX_CHAR_UUID),
          CBUUID(string: TX_CHAR_UUID)
        ],
        for: service
      )
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    
    if let error = error {
      onGattInfo(message: "[\(strUUID)] RX/TX characteristic를 찾는 중 오류가 발생하였습니다. error: \(error)")
      disconnetPeripheral(peripheral)
      return
    }
    
    guard let characteristics = service.characteristics else {
      onGattInfo(message: "[\(strUUID)] RX/TX characteristic를 찾을 수 없습니다.")
      disconnetPeripheral(peripheral)
      return
    }
    
    for characteristic in characteristics {
      if characteristic.uuid == CBUUID(string: RX_CHAR_UUID) {
        onGattInfo(message: "[\(strUUID)] RX characteristic를 찾았습니다.")
        rxCharacteristicDict[strUUID] = characteristic
      } else if characteristic.uuid == CBUUID(string: TX_CHAR_UUID) {
        onGattInfo(message: "[\(strUUID)] TX characteristic를 찾았습니다.")
        txCharacteristicDict[strUUID] = characteristic
      }
    }
    
    if let rxChar = rxCharacteristicDict[strUUID] {
      peripheral.setNotifyValue(true, for: rxChar)
    } else {
      onGattInfo(message: "[\(strUUID)] RX characteristic가 없어 노티피케이션을 구독할 수 없습니다.")
      disconnetPeripheral(peripheral)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    
    if let error = error {
      onGattInfo(message: "[\(strUUID)] 노티피케이션 구독 중 오류가 발생하였습니다. error: \(error)")
      disconnetPeripheral(peripheral)
      return
    }
    
    if let txChar = txCharacteristicDict[strUUID] {
      // let bytes: [UInt8] = [0x02, 0x10, 0x00, 0x00, 0x50, 0x30, 0x30, 0x42, 0x43, 0x36, 0x31, 0x34, 0x45, 0x03, 0xf9, 0xc6]
      let authKey = bleIdentificationData?.authKey ?? ""
      let packetBytes = BleIdentificationServiceUtils.generateUserAccessPacket(authKey: authKey)
      let packetValue = Data(bytes: packetBytes, count: packetBytes.count)
      peripheral.writeValue(packetValue, for: txChar, type: .withResponse)
      
      let hexStr = DataUtils.dataToHexString(input: packetValue, separator: " ")
      onGattInfo(message: "[\(strUUID)] Write data: \(hexStr)")
    } else {
      onGattInfo(message: "[\(strUUID)] TX characteristic가 없어 데이터를 전송할 수 없습니다.")
      disconnetPeripheral(peripheral)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    
    if let error = error {
      onGattError(
        error: ServiceErrorCodes
          .WRITE_CHARACTERISTIC_FAILED
          .toModel(errorMessage: "[\(strUUID)] 데이터 전송 중 오류가 발생하였습니다. error: \(error)")
      )
      disconnetPeripheral(peripheral)
      return
    }
    
    let peripheralSessionTimeoutWork = DispatchWorkItem {
      sleep(UInt32(PERIPHERAL_SESSION_TIMEOUT))
      
      if self.peripheralSessionTimeoutWorkDict[strUUID]?.isCancelled ?? true {
        return
      }
      
      self.onGattError(
        error: ServiceErrorCodes
          .ACCESS_USER_TIMEOUT
          .toModel(errorMessage: "[\(strUUID)] 출입 인증 요청 응답시간이 초과되었습니다.")
      )
      self.disconnetPeripheral(peripheral)
    }
    
    DispatchQueue.global(qos: .userInitiated).async(execute: peripheralSessionTimeoutWork)
    peripheralSessionTimeoutWorkDict[strUUID] = peripheralSessionTimeoutWork
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    let strUUID = peripheral.identifier.uuidString
    
    if let error = error {
      onGattError(
        error: ServiceErrorCodes
          .READ_CHARACTERISTIC_FAILED
          .toModel(errorMessage: "[\(strUUID)] 데이터 수신 중 오류가 발생하였습니다. error: \(error)")
      )
      disconnetPeripheral(peripheral)
      return
    }
    
    if let responseData = characteristic.value, responseData.count >= 8 {
      let hexStr = DataUtils.dataToHexString(input: responseData, separator: " ")
      onGattInfo(message: "[\(strUUID)] Read data: \(hexStr)")
      let result = AccessResultCodes.fromByte(byte: responseData[4]).toModel()
      onAccessResult(result: result)
    }
    
    disconnetPeripheral(peripheral)
  }
}
