package com.pravera.flutter_ble_identification.errors

import android.bluetooth.le.ScanCallback

enum class ServiceErrorCodes {
    SCAN_FAILED_ALREADY_STARTED,
    SCAN_FAILED_APPLICATION_REGISTRATION_FAILED,
    SCAN_FAILED_FEATURE_UNSUPPORTED,
    SCAN_FAILED_INTERNAL_ERROR,
    WRITE_CHARACTERISTIC_FAILED,
    READ_CHARACTERISTIC_FAILED,
    ACCESS_USER_TIMEOUT,
    ACCESS_USER_FAILED,
    UNKNOWN_ERROR;

    fun message(): String {
        return when (this) {
            SCAN_FAILED_ALREADY_STARTED -> "Fails to start scan as BLE scan with the same settings is already started by the app."
            SCAN_FAILED_APPLICATION_REGISTRATION_FAILED -> "Fails to start scan as app cannot be registered."
            SCAN_FAILED_FEATURE_UNSUPPORTED -> "Fails to start power optimized scan as this feature is not supported."
            SCAN_FAILED_INTERNAL_ERROR -> "Fails to start scan due an internal error."
            WRITE_CHARACTERISTIC_FAILED -> "Fails to write characteristic."
            READ_CHARACTERISTIC_FAILED -> "Fails to read characteristic."
            ACCESS_USER_TIMEOUT -> "출입 인증 요청 응답시간이 초과되었습니다."
            ACCESS_USER_FAILED -> "출입 인증 요청에 실패하였습니다."
            UNKNOWN_ERROR -> "An unknown error has occurred."
        }
    }

    fun toModel(errorMessage: String? = null): ServiceError {
        return ServiceError(this.name, errorMessage ?: this.message())
    }

    companion object {
        fun fromScanErrorCode(errorCode: Int): ServiceErrorCodes {
            return when (errorCode) {
                ScanCallback.SCAN_FAILED_ALREADY_STARTED -> SCAN_FAILED_ALREADY_STARTED
                ScanCallback.SCAN_FAILED_APPLICATION_REGISTRATION_FAILED -> SCAN_FAILED_APPLICATION_REGISTRATION_FAILED
                ScanCallback.SCAN_FAILED_FEATURE_UNSUPPORTED -> SCAN_FAILED_FEATURE_UNSUPPORTED
                ScanCallback.SCAN_FAILED_INTERNAL_ERROR -> SCAN_FAILED_INTERNAL_ERROR
                else -> UNKNOWN_ERROR
            }
        }
    }
}
