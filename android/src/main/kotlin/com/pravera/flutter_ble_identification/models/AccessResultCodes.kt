package com.pravera.flutter_ble_identification.models

import com.pravera.flutter_ble_identification.utils.BytesUtils

enum class AccessResultCodes {
    COMM_SUCCESS,
    COMM_WRONG_CRC,
    COMM_INVALID_COMMAND,
    COMM_WRONG_LENGTH,
    COMM_WRITE_FAIL,
    COMM_WRONG_DATA,
    COMM_FLOW_ERROR,
    COMM_ADMIN_MODE_FAIL,
    COMM_ADMIN_AUTH_FAIL,
    COMM_AUTH_FAIL,
    COMM_AUTH_METHOD_FAIL,
    UNKNOWN;

    fun message(): String {
        return when (this) {
            COMM_SUCCESS -> "명령어가 성공적으로 수행되었음"
            COMM_WRONG_CRC -> "명령패킷의 CRC 값이 맞지 않음"
            COMM_INVALID_COMMAND -> "명령이 존재하지 않음"
            COMM_WRONG_LENGTH -> "명령패킷의 Data 사이즈가 맞지 않음"
            COMM_WRITE_FAIL -> "메모리에 쓰기 실패"
            COMM_WRONG_DATA -> "명령패킷의 Data 구성이 잘못됨"
            COMM_FLOW_ERROR -> "메모리 쓰기 순서가 맞지 않음"
            COMM_ADMIN_MODE_FAIL -> "관리자 모드가 아님"
            COMM_ADMIN_AUTH_FAIL -> "관리자 인증 실패"
            COMM_AUTH_FAIL -> "MAC 인증 실패"
            COMM_AUTH_METHOD_FAIL -> "사용자 인증 방법이 맞지 않음"
            UNKNOWN -> "알 수 없는 코드임"
        }
    }

    fun toModel(resultMessage: String? = null): AccessResult {
        return AccessResult(this.name, resultMessage ?: this.message())
    }

    companion object {
        fun fromByte(byte: Byte): AccessResultCodes {
            return when (BytesUtils.bytesToHexString(byteArrayOf(byte))) {
                "00" -> COMM_SUCCESS
                "01" -> COMM_WRONG_CRC
                "02" -> COMM_INVALID_COMMAND
                "03" -> COMM_WRONG_LENGTH
                "04" -> COMM_WRITE_FAIL
                "05" -> COMM_WRONG_DATA
                "06" -> COMM_FLOW_ERROR
                "0A" -> COMM_ADMIN_MODE_FAIL
                "0B" -> COMM_ADMIN_AUTH_FAIL
                "0D" -> COMM_AUTH_FAIL
                "0F" -> COMM_AUTH_METHOD_FAIL
                else -> UNKNOWN
            }
        }
    }
}
