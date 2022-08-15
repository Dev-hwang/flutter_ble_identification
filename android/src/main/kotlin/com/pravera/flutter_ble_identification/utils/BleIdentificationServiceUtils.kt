package com.pravera.flutter_ble_identification.utils

import java.util.*

private const val PACKET_MINIMUM_LENGTH = 8
private const val PACKET_HEADER_AREA_LENGTH = 5
private const val PACKET_INT_VALUE: Byte = 0x00
private const val PACKET_STX_VALUE: Byte = 0x02
private const val PACKET_ETX_VALUE: Byte = 0x03

class BleIdentificationServiceUtils {
    companion object {
        fun generateUserAccessPacket(authKey: String): ByteArray {
            val data: ByteArray
            val hexAuthKey = Integer
                .toHexString(authKey.toIntOrNull() ?: 0)
                .toUpperCase(Locale.getDefault())
            val hexAuthKeyLength = hexAuthKey.length
            if (hexAuthKeyLength < 8) {
                val zeroPaddingCount = 8 - hexAuthKeyLength
                var zeroPadding = ""
                for (i in 1..zeroPaddingCount) {
                    zeroPadding += "0"
                }
                data = (zeroPadding + hexAuthKey).toByteArray()
            } else {
                data = hexAuthKey.toByteArray()
            }

            return generateCommandPacket(0x50, data, false)
        }

        fun generateCommandPacket(
            command: Byte,
            data: ByteArray,
            encryptData: Boolean = true
        ): ByteArray {
            val dataArea = if (data.isNotEmpty() && encryptData) {
                // TODO: 암호화 통신 방식 확인 필요
                CipherUtils.encryptAES128(data, withPadding = true)
            } else {
                data
            }

            // 통신 프로토콜에 따른 패킷 생성

            return ByteArray(8)
        }

        fun generate2BytesCrcCode(input: ByteArray): ByteArray {
            val crcCode = ByteArray(2)
            val crc16 = CRC16()
            crc16.update(input)
            write2BytesToBuffer(crcCode, 0, crc16.getValue())

            return crcCode
        }

        fun write2BytesToBuffer(buffer: ByteArray, offset: Int, input: Int) {
            buffer[offset + 0] = (input shr 0).toByte()
            buffer[offset + 1] = (input shr 8).toByte()
        }
    }
}
