package com.pravera.flutter_ble_identification.service

interface BleIdentificationServiceCallback {
    fun onAccessSuccess(resultCode: String)
    fun onAccessFailure(resultCode: String)
    fun onScanError(errorJson: String)
    fun onGattError(errorJson: String)
    fun onGattInfo(message: String)
}
