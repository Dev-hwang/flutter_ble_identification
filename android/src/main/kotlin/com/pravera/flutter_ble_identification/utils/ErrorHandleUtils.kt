package com.pravera.flutter_ble_identification.utils

import com.pravera.flutter_ble_identification.errors.PluginErrorCodes
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class ErrorHandleUtils {
	companion object {
		fun handleMethodCallError(result: MethodChannel.Result?, errorCodes: PluginErrorCodes) {
			result?.error(errorCodes.toString(), errorCodes.message(), null)
		}

		fun handleStreamError(events: EventChannel.EventSink?, errorCodes: PluginErrorCodes) {
			events?.error(errorCodes.toString(), errorCodes.message(), null)
		}
	}
}
