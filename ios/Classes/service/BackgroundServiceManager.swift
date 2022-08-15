//
//  BackgroundServiceManager.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

class BackgroundServiceManager: NSObject {
  func start(call: FlutterMethodCall) -> Bool {
    if #available(iOS 10.0, *) {
      let argsDict = call.arguments as? Dictionary<String, Any>
      BackgroundServiceOptions.putData(dict: argsDict)
      BleScannerOptions.putData(dict: argsDict)
      BleIdentificationData.putData(dict: argsDict)
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.START)
    } else {
      // Fallback on earlier versions
      return false
    }
    
    return true
  }
  
  func restart(call: FlutterMethodCall) -> Bool {
    if #available(iOS 10.0, *) {
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.RESTART)
    } else {
      // Fallback on earlier versions
      return false
    }
    
    return true
  }
  
  func update(call: FlutterMethodCall) -> Bool {
    if #available(iOS 10.0, *) {
      let argsDict = call.arguments as? Dictionary<String, Any>
      BackgroundServiceOptions.updateCallbackHandle(dict: argsDict)
      BleIdentificationData.updateAuthKey(dict: argsDict)
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.UPDATE)
    } else {
      // Fallback on earlier versions
      return false
    }
    
    return true
  }
  
  func stop() -> Bool {
    if #available(iOS 10.0, *) {
      BackgroundServiceOptions.clearData()
      BleScannerOptions.clearData()
      BleIdentificationData.clearData()
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.STOP)
    } else {
      // Fallback on earlier versions
      return false
    }
    
    return true
  }
  
  func isRunningService() -> Bool {
    if #available(iOS 10.0, *) {
      return BackgroundService.sharedInstance.isRunningService
    } else {
      return false
    }
  }
}
