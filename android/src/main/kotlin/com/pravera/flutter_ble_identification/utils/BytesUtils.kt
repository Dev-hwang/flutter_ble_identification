package com.pravera.flutter_ble_identification.utils

class BytesUtils {
    companion object {
        fun hexStringToBytes(input: String): ByteArray {
            return input.chunked(2)
                .map { it.toInt(16).toByte() }
                .toByteArray()
        }

        fun bytesToHexString(input: ByteArray, separator: String = ""): String {
            return input.joinToString(separator = separator) { byte -> "%02x".format(byte) }
        }
    }
}
