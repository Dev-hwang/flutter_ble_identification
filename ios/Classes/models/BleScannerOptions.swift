//
//  BleScannerOptions.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

class BleScannerOptions {
  let deviceAddressFilters: [String]
  let deviceNameFilters: [String]
  let serviceUuidFilters: [String]
  
  init(deviceAddressFilters: [String], deviceNameFilters: [String], serviceUuidFilters: [String]) {
    self.deviceAddressFilters = deviceAddressFilters
    self.deviceNameFilters = deviceNameFilters
    self.serviceUuidFilters = serviceUuidFilters
  }
  
  static func getData() -> BleScannerOptions {
    let prefs = UserDefaults.standard
    let deviceAddressFilters = prefs.object(forKey: DEVICE_ADDRESS_FILTERS) as? [String]
    let deviceNameFilters = prefs.object(forKey: DEVICE_NAME_FILTERS) as? [String]
    let serviceUuidFilters = prefs.object(forKey: SERVICE_UUID_FILTERS) as? [String]
    
    return BleScannerOptions(
      deviceAddressFilters: deviceAddressFilters ?? [],
      deviceNameFilters: deviceNameFilters ?? [],
      serviceUuidFilters: serviceUuidFilters ?? []
    )
  }
  
  static func putData(dict: Dictionary<String, Any>?) {
    let deviceAddressFilters = dict?[DEVICE_ADDRESS_FILTERS] as? [String]
    let deviceNameFilters = dict?[DEVICE_NAME_FILTERS] as? [String]
    let serviceUuidFilters = dict?[SERVICE_UUID_FILTERS] as? [String]
    
    let prefs = UserDefaults.standard
    prefs.set(deviceAddressFilters, forKey: DEVICE_ADDRESS_FILTERS)
    prefs.set(deviceNameFilters, forKey: DEVICE_NAME_FILTERS)
    prefs.set(serviceUuidFilters, forKey: SERVICE_UUID_FILTERS)
  }
  
  static func clearData() {
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: DEVICE_ADDRESS_FILTERS)
    prefs.removeObject(forKey: DEVICE_NAME_FILTERS)
    prefs.removeObject(forKey: SERVICE_UUID_FILTERS)
  }
}
