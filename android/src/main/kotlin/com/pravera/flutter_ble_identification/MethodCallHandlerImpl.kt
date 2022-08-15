package com.pravera.flutter_ble_identification

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.pravera.flutter_ble_identification.errors.PluginErrorCodes
import com.pravera.flutter_ble_identification.service.ServiceProvider
import com.pravera.flutter_ble_identification.utils.BatteryOptimizationUtils
import com.pravera.flutter_ble_identification.utils.BluetoothUtils
import com.pravera.flutter_ble_identification.utils.ErrorHandleUtils

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

private const val REQUEST_ENABLE_BT = 1
private const val REQUEST_IGNORE_BATTERY_OPTIMIZATION = 2

class MethodCallHandlerImpl(
	private val context: Context,
	private val serviceProvider: ServiceProvider
	) : MethodChannel.MethodCallHandler,
		FlutterBleIdentificationPluginChannel,
		PluginRegistry.ActivityResultListener {

	private lateinit var channel: MethodChannel
	private var activity: Activity? = null
	private var requestEnableBtResult: Result? = null
	private var requestIgnoreBatteryOptimizationResult: Result? = null

	override fun onMethodCall(call: MethodCall, result: Result) {
		val callMethod = call.method
		val callArguments = call.arguments
		if (callMethod.equals("requestEnableBt") ||
			callMethod.equals("requestIgnoreBatteryOptimization")) {
			if (activity == null) {
				ErrorHandleUtils.handleMethodCallError(result, PluginErrorCodes.ACTIVITY_NOT_ATTACHED)
				return
			}
		}

		when (callMethod) {
			"startForegroundService" ->
				result.success(serviceProvider.getForegroundServiceManager().start(context, callArguments))
			"restartForegroundService" ->
				result.success(serviceProvider.getForegroundServiceManager().restart(context, callArguments))
			"updateForegroundService" ->
				result.success(serviceProvider.getForegroundServiceManager().update(context, callArguments))
			"stopForegroundService" ->
				result.success(serviceProvider.getForegroundServiceManager().stop(context))
			"isRunningService" ->
				result.success(serviceProvider.getForegroundServiceManager().isRunningService())
			"isSupportedBle" -> result.success(BluetoothUtils.isSupportedBle(context))
			"isSupportedBt" -> result.success(BluetoothUtils.isSupportedBt(context))
			"isEnabledBt" -> result.success(BluetoothUtils.isEnabledBt(context))
			"requestEnableBt" -> {
				if (BluetoothUtils.requestEnableBt(activity, REQUEST_ENABLE_BT)) {
					requestEnableBtResult = result
				} else {
					result.success(BluetoothUtils.isEnabledBt(context))
				}
			}
			"isIgnoringBatteryOptimizations" ->
				result.success(BatteryOptimizationUtils.isIgnoringBatteryOptimizations(context))
			"requestIgnoreBatteryOptimization" -> {
				requestIgnoreBatteryOptimizationResult = result
				BatteryOptimizationUtils.requestIgnoreBatteryOptimization(
					activity,
					REQUEST_IGNORE_BATTERY_OPTIMIZATION
				)
			}
			else -> result.notImplemented()
		}
	}

	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
		when (requestCode) {
			REQUEST_ENABLE_BT -> {
				val isEnabled = BluetoothUtils.isEnabledBt(context)
				requestEnableBtResult?.success(isEnabled)
				requestEnableBtResult = null
			}
			REQUEST_IGNORE_BATTERY_OPTIMIZATION -> {
				val isIgnored = BatteryOptimizationUtils.isIgnoringBatteryOptimizations(context)
				requestIgnoreBatteryOptimizationResult?.success(isIgnored)
				requestIgnoreBatteryOptimizationResult = null
			}
		}

		return resultCode == Activity.RESULT_OK
	}

	override fun init(messenger: BinaryMessenger) {
		channel = MethodChannel(messenger, "flutter_ble_identification/method")
		channel.setMethodCallHandler(this)
	}

	override fun setActivity(activity: Activity?) {
		this.activity = activity
	}

	override fun dispose() {
		if (::channel.isInitialized) {
			channel.setMethodCallHandler(null)
		}
	}
}
