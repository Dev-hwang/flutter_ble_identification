package com.pravera.flutter_ble_identification.models

import android.content.Context
import com.pravera.flutter_ble_identification.service.ForegroundServiceAction
import com.pravera.flutter_ble_identification.service.PrefsKey

data class ForegroundServiceStatus(val action: String) {
    companion object {
        fun putData(context: Context, action: String) {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_STATUS_PREFS_NAME, Context.MODE_PRIVATE)

            with (prefs.edit()) {
                putString(PrefsKey.SERVICE_ACTION, action)
                commit()
            }
        }

        fun getData(context: Context): ForegroundServiceStatus {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_STATUS_PREFS_NAME, Context.MODE_PRIVATE)

            val action = prefs.getString(PrefsKey.SERVICE_ACTION, null)
                ?: ForegroundServiceAction.STOP

            return ForegroundServiceStatus(action = action)
        }
    }
}
