package com.pravera.flutter_ble_identification

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

interface FlutterBleIdentificationPluginChannel {
	fun init(messenger: BinaryMessenger)
	fun setActivity(activity: Activity?)
	fun dispose()
}
