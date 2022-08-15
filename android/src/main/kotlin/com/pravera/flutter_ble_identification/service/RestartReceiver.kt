package com.pravera.flutter_ble_identification.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class RestartReceiver: BroadcastReceiver() {
	override fun onReceive(context: Context?, intent: Intent?) {
		val ssPrefs = context?.getSharedPreferences(
			PrefsKey.SERVICE_STATUS_PREFS_NAME, Context.MODE_PRIVATE) ?: return

		val nIntent = Intent(context, ForegroundService::class.java)
		with (ssPrefs.edit()) {
			putString(PrefsKey.SERVICE_ACTION, ForegroundServiceAction.RESTART)
			commit()
		}

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			context.startForegroundService(nIntent)
		} else {
			context.startService(nIntent)
		}
	}
}
