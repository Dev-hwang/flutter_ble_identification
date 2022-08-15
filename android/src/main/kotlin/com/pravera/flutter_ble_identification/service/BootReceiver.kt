package com.pravera.flutter_ble_identification.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.intent.action.BOOT_COMPLETED") {
            // Check whether to start the service at boot time.
            val soPrefs = context?.getSharedPreferences(
                PrefsKey.SERVICE_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE) ?: return
            if (!soPrefs.getBoolean(PrefsKey.AUTO_RUN_ON_BOOT, false)) return

            // Create an intent for calling the service and store the action to be executed.
            val nIntent = Intent(context, ForegroundService::class.java)
            val ssPrefs = context.getSharedPreferences(
                PrefsKey.SERVICE_STATUS_PREFS_NAME, Context.MODE_PRIVATE)
            with (ssPrefs.edit()) {
                putString(PrefsKey.SERVICE_ACTION, ForegroundServiceAction.REBOOT)
                commit()
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(nIntent)
            } else {
                context.startService(nIntent)
            }
        }
    }
}
