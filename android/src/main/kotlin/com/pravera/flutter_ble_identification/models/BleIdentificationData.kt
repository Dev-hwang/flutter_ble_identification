package com.pravera.flutter_ble_identification.models

import android.content.Context
import com.pravera.flutter_ble_identification.service.PrefsKey

data class BleIdentificationData(val authKey: String) {
    companion object {
        fun putData(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_IDENTIFICATION_DATA_PREFS_NAME, Context.MODE_PRIVATE)

            val authKey = map?.get(PrefsKey.AUTH_KEY) as? String

            with (prefs.edit()) {
                putString(PrefsKey.AUTH_KEY, authKey)
                commit()
            }
        }

        fun updateAuthKey(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_IDENTIFICATION_DATA_PREFS_NAME, Context.MODE_PRIVATE)

            val authKey = map?.get(PrefsKey.AUTH_KEY) as? String
                ?: prefs.getString(PrefsKey.AUTH_KEY, null)
                ?: ""

            with (prefs.edit()) {
                putString(PrefsKey.AUTH_KEY, authKey)
                commit()
            }
        }

        fun getData(context: Context): BleIdentificationData {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_IDENTIFICATION_DATA_PREFS_NAME, Context.MODE_PRIVATE)

            val authKey = prefs.getString(PrefsKey.AUTH_KEY, null) ?: ""

            return BleIdentificationData(authKey = authKey)
        }

        fun clearData(context: Context) {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_IDENTIFICATION_DATA_PREFS_NAME, Context.MODE_PRIVATE)

            with (prefs.edit()) {
                clear()
                commit()
            }
        }
    }
}
