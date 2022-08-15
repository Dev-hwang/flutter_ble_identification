//
//  BackgroundServiceOptions.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

class BackgroundServiceOptions {
  let callbackHandle: Int64?
  let callbackHandleOnRestart: Int64?
  
  init(callbackHandle: Int64?, callbackHandleOnRestart: Int64?) {
    self.callbackHandle = callbackHandle
    self.callbackHandleOnRestart = callbackHandleOnRestart
  }
  
  static func getData() -> BackgroundServiceOptions {
    let prefs = UserDefaults.standard
    let callbackHandle = prefs.object(forKey: CALLBACK_HANDLE) as? Int64
    let callbackHandleOnRestart = prefs.object(forKey: CALLBACK_HANDLE_ON_RESTART) as? Int64
    
    return BackgroundServiceOptions(
      callbackHandle: callbackHandle,
      callbackHandleOnRestart: callbackHandleOnRestart
    )
  }
  
  static func putData(dict: Dictionary<String, Any>?) {
    let callbackHandle = dict?[CALLBACK_HANDLE] as? Int64
    
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: CALLBACK_HANDLE)
    prefs.removeObject(forKey: CALLBACK_HANDLE_ON_RESTART)
    if callbackHandle != nil {
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE)
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE_ON_RESTART)
    }
  }
  
  static func updateCallbackHandle(dict: Dictionary<String, Any>?) {
    let callbackHandle = dict?[CALLBACK_HANDLE] as? Int64
    
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: CALLBACK_HANDLE)
    if callbackHandle != nil {
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE)
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE_ON_RESTART)
    }
  }
  
  static func clearData() {
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: CALLBACK_HANDLE)
    prefs.removeObject(forKey: CALLBACK_HANDLE_ON_RESTART)
  }
}
