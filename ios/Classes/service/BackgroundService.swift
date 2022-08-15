//
//  BackgroundService.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

let BG_ISOLATE_NAME: String = "flutter_ble_identification/backgroundIsolate"
let BG_CHANNEL_NAME: String = "flutter_ble_identification/background"
let ACTION_BACKGROUND_SERVICE_START: String = "onStart"
let ACTION_ACCESS_SUCCESS: String = "onAccessSuccess"
let ACTION_ACCESS_FAILURE: String = "onAccessFailure"
let ACTION_SCAN_ERROR: String = "onScanError"
let ACTION_GATT_ERROR: String = "onGattError"
let ACTION_GATT_INFO: String = "onGattInfo"
let ACTION_BACKGROUND_SERVICE_DESTROY: String = "onDestroy"

@available(iOS 10.0, *)
class BackgroundService: NSObject, BleIdentificationServiceCallback {
  static let sharedInstance = BackgroundService()
  
  var isRunningService: Bool = false
  
  private var currFlutterEngine: FlutterEngine? = nil
  private var backgroundChannel: FlutterMethodChannel? = nil
  private let bleIdentificationService = BleIdentificationService()
  
  func run(action: BackgroundServiceAction) {
    let backgroundServiceOptions = BackgroundServiceOptions.getData()
    
    switch action {
      case .START:
        isRunningService = true
        if let callbackHandle = backgroundServiceOptions.callbackHandle {
          executeDartCallback(callbackHandle: callbackHandle)
        }
        break
      case .RESTART:
        isRunningService = true
        if let callbackHandle = backgroundServiceOptions.callbackHandleOnRestart {
          executeDartCallback(callbackHandle: callbackHandle)
        }
        break
      case .UPDATE:
        isRunningService = true
        if let callbackHandle = backgroundServiceOptions.callbackHandleOnRestart {
          executeDartCallback(callbackHandle: callbackHandle)
        }
        break
      case .STOP:
        destroyBackgroundService() { _ in
          self.isRunningService = false
        }
        break
    }
  }
  
  private func executeDartCallback(callbackHandle: Int64) {
    destroyBackgroundService() { _ in
      // The backgroundChannel cannot be registered unless the registerPlugins function is called.
      if (SwiftFlutterBleIdentificationPlugin.registerPlugins == nil) { return }
      
      self.currFlutterEngine = FlutterEngine(name: BG_ISOLATE_NAME, project: nil, allowHeadlessExecution: true)
      let callbackInfo = FlutterCallbackCache.lookupCallbackInformation(callbackHandle)
      let entrypoint = callbackInfo?.callbackName
      let uri = callbackInfo?.callbackLibraryPath
      self.currFlutterEngine?.run(withEntrypoint: entrypoint, libraryURI: uri)
      
      SwiftFlutterBleIdentificationPlugin.registerPlugins!(self.currFlutterEngine!)
      
      let binaryMessenger = self.currFlutterEngine!.binaryMessenger
      self.backgroundChannel = FlutterMethodChannel(name: BG_CHANNEL_NAME, binaryMessenger: binaryMessenger)
      self.backgroundChannel?.setMethodCallHandler(self.onMethodCall)
    }
  }
  
  private func startBleIdentificationService() {
    backgroundChannel?.invokeMethod(ACTION_BACKGROUND_SERVICE_START, arguments: nil) { _ in
      self.bleIdentificationService.start(callback: self)
    }
  }
  
  private func stopBleIdentificationService() {
    bleIdentificationService.stop()
  }
  
  private func destroyBackgroundService(onComplete: @escaping (Bool) -> Void) {
    stopBleIdentificationService()
    
    if backgroundChannel == nil {
      onComplete(true)
    } else {
      backgroundChannel?.invokeMethod(ACTION_BACKGROUND_SERVICE_DESTROY, arguments: nil) { _ in
        self.currFlutterEngine?.destroyContext()
        self.currFlutterEngine = nil
        self.backgroundChannel = nil
        onComplete(true)
      }
    }
  }
  
  private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "startBackgroundService":
        startBleIdentificationService()
      default:
        result(FlutterMethodNotImplemented)
    }
  }
  
  func onAccessSuccess(resultCode: String) {
    backgroundChannel?.invokeMethod(ACTION_ACCESS_SUCCESS, arguments: resultCode)
  }
  
  func onAccessFailure(resultCode: String) {
    backgroundChannel?.invokeMethod(ACTION_ACCESS_FAILURE, arguments: resultCode)
  }
  
  func onScanError(errorJson: String) {
    backgroundChannel?.invokeMethod(ACTION_SCAN_ERROR, arguments: errorJson)
  }
  
  func onGattError(errorJson: String) {
    backgroundChannel?.invokeMethod(ACTION_GATT_ERROR, arguments: errorJson)
  }
  
  func onGattInfo(message: String) {
    backgroundChannel?.invokeMethod(ACTION_GATT_INFO, arguments: message)
  }
}
