//
//  BleIdentificationData.swift
//  flutter_ble_identification
//
//  Created by WOO JIN HWANG on 2022/06/09.
//

import Foundation

class BleIdentificationData {
  let authKey: String
  
  init(authKey: String) {
    self.authKey = authKey
  }
  
  static func getData() -> BleIdentificationData {
    let prefs = UserDefaults.standard
    let authKey = prefs.object(forKey: AUTH_KEY) as? String ?? ""
    
    return BleIdentificationData(authKey: authKey)
  }
  
  static func putData(dict: Dictionary<String, Any>?) {
    let authKey = dict?[AUTH_KEY] as? String
    
    let prefs = UserDefaults.standard
    prefs.set(authKey, forKey: AUTH_KEY)
  }
  
  static func updateAuthKey(dict: Dictionary<String, Any>?) {
    let prefs = UserDefaults.standard
    let authKey = dict?[AUTH_KEY] as? String
        ?? prefs.object(forKey: AUTH_KEY) as? String
        ?? ""
    
    prefs.set(authKey, forKey: AUTH_KEY)
  }
  
  static func clearData() {
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: AUTH_KEY)
  }
}
