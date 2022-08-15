package com.pravera.flutter_ble_identification.models

import android.content.Context
import com.pravera.flutter_ble_identification.service.PrefsKey

data class ForegroundServiceOptions(
    val autoRunOnBoot: Boolean,
    val allowWifiLock: Boolean,
    val callbackHandle: Long?,
    val callbackHandleOnBoot: Long?
    ) {
    companion object {
        fun putData(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            val autoRunOnBoot = map?.get(PrefsKey.AUTO_RUN_ON_BOOT) as? Boolean ?: false
            val allowWifiLock = map?.get(PrefsKey.ALLOW_WIFI_LOCK) as? Boolean ?: false
            val callbackHandle = "${map?.get(PrefsKey.CALLBACK_HANDLE)}".toLongOrNull()

            with (prefs.edit()) {
                putBoolean(PrefsKey.AUTO_RUN_ON_BOOT, autoRunOnBoot)
                putBoolean(PrefsKey.ALLOW_WIFI_LOCK, allowWifiLock)
                remove(PrefsKey.CALLBACK_HANDLE)
                remove(PrefsKey.CALLBACK_HANDLE_ON_BOOT)
                if (callbackHandle != null) {
                    putLong(PrefsKey.CALLBACK_HANDLE, callbackHandle)
                    putLong(PrefsKey.CALLBACK_HANDLE_ON_BOOT, callbackHandle)
                }
                commit()
            }
        }

        fun updateCallbackHandle(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            val callbackHandle = "${map?.get(PrefsKey.CALLBACK_HANDLE)}".toLongOrNull()

            with (prefs.edit()) {
                remove(PrefsKey.CALLBACK_HANDLE)
                if (callbackHandle != null) {
                    putLong(PrefsKey.CALLBACK_HANDLE, callbackHandle)
                    putLong(PrefsKey.CALLBACK_HANDLE_ON_BOOT, callbackHandle)
                }
                commit()
            }
        }

        fun getData(context: Context): ForegroundServiceOptions {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            val autoRunOnBoot = prefs.getBoolean(PrefsKey.AUTO_RUN_ON_BOOT, false)
            val allowWifiLock = prefs.getBoolean(PrefsKey.ALLOW_WIFI_LOCK, false)
            val callbackHandle = if (prefs.contains(PrefsKey.CALLBACK_HANDLE)) {
                prefs.getLong(PrefsKey.CALLBACK_HANDLE, 0L)
            } else {
                null
            }
            val callbackHandleOnBoot = if (prefs.contains(PrefsKey.CALLBACK_HANDLE_ON_BOOT)) {
                prefs.getLong(PrefsKey.CALLBACK_HANDLE_ON_BOOT, 0L)
            } else {
                null
            }

            return ForegroundServiceOptions(
                autoRunOnBoot = autoRunOnBoot,
                allowWifiLock = allowWifiLock,
                callbackHandle = callbackHandle,
                callbackHandleOnBoot = callbackHandleOnBoot
            )
        }

        fun clearData(context: Context) {
            val prefs = context.getSharedPreferences(
                PrefsKey.SERVICE_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            with (prefs.edit()) {
                clear()
                commit()
            }
        }
    }
}
