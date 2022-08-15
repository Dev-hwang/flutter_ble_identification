package com.pravera.flutter_ble_identification.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

class BatteryOptimizationUtils {
	companion object {
		fun isIgnoringBatteryOptimizations(context: Context): Boolean {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
				return powerManager.isIgnoringBatteryOptimizations(context.packageName)
			}

			return true
		}

		fun requestIgnoreBatteryOptimization(activity: Activity?, recCode: Int) {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
				intent.data = Uri.parse("package:" + activity?.packageName)
				activity?.startActivityForResult(intent, recCode)
			}
		}
	}
}
