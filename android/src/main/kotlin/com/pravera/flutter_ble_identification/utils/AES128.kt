package com.pravera.flutter_ble_identification.utils

import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

private const val USER_KEY = "ADE8D0A08B72185AA9C9FB2DD8B4CF66"
private const val USER_IV = "C23C1B68B325C6079460150AA987F5C1"

class CipherUtils {
    companion object {
        fun insertPadding(bytes: ByteArray): ByteArray {
            val paddingBytes = if (bytes.size >= 16) {
                ByteArray(32 - bytes.size)
            } else {
                ByteArray(16 - bytes.size)
            }

            if (bytes.size % 2 == 0) {
                paddingBytes[0] = 0x80.toByte()
            }

            return bytes + paddingBytes
        }

        fun encryptAES128(plainBytes: ByteArray, withPadding: Boolean = false): ByteArray {
            val paddedBytes = if (withPadding) {
                insertPadding(plainBytes)
            } else {
                plainBytes
            }

            val iv = IvParameterSpec(BytesUtils.hexStringToBytes(USER_IV))
            val key = SecretKeySpec(BytesUtils.hexStringToBytes(USER_KEY), "AES")
            val cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING")
            cipher.init(Cipher.ENCRYPT_MODE, key, iv)

            return cipher.doFinal(paddedBytes)
        }

        fun decryptAES128(cipherBytes: ByteArray): ByteArray {
            val iv = IvParameterSpec(BytesUtils.hexStringToBytes(USER_IV))
            val key = SecretKeySpec(BytesUtils.hexStringToBytes(USER_KEY), "AES")
            val cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING")
            cipher.init(Cipher.DECRYPT_MODE, key, iv)

            return cipher.doFinal(cipherBytes)
        }
    }
}
