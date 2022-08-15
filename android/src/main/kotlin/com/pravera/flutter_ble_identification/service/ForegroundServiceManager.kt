package com.pravera.flutter_ble_identification.service

import android.content.Context
import android.content.Intent
import android.os.Build
import com.pravera.flutter_ble_identification.models.*

class ForegroundServiceManager {
    fun start(context: Context, arguments: Any?): Boolean {
        try {
            val nIntent = Intent(context, ForegroundService::class.java)
            val argsMap = arguments as? Map<*, *>
            ForegroundServiceStatus.putData(context, ForegroundServiceAction.START)
            ForegroundServiceOptions.putData(context, argsMap)
            NotificationOptions.putData(context, argsMap)
            BleScannerOptions.putData(context, argsMap)
            BleIdentificationData.putData(context, argsMap)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(nIntent)
            } else {
                context.startService(nIntent)
            }
        } catch (e: Exception) {
            return false
        }

        return true
    }

    fun restart(context: Context, arguments: Any?): Boolean {
        try {
            val intent = Intent(context, ForegroundService::class.java)
            ForegroundServiceStatus.putData(context, ForegroundServiceAction.RESTART)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        } catch (e: Exception) {
            return false
        }

        return true
    }

    fun update(context: Context, arguments: Any?): Boolean {
        try {
            val nIntent = Intent(context, ForegroundService::class.java)
            val argsMap = arguments as? Map<*, *>
            ForegroundServiceStatus.putData(context, ForegroundServiceAction.UPDATE)
            ForegroundServiceOptions.updateCallbackHandle(context, argsMap)
            NotificationOptions.updateContent(context, argsMap)
            BleIdentificationData.updateAuthKey(context, argsMap)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(nIntent)
            } else {
                context.startService(nIntent)
            }
        } catch (e: Exception) {
            return false
        }

        return true
    }

    fun stop(context: Context): Boolean {
        // If the service is not running, the stop function is not executed.
        if (!ForegroundService.isRunningService) return false

        try {
            val nIntent = Intent(context, ForegroundService::class.java)
            ForegroundServiceStatus.putData(context, ForegroundServiceAction.STOP)
            ForegroundServiceOptions.clearData(context)
            NotificationOptions.clearData(context)
            BleScannerOptions.clearData(context)
            BleIdentificationData.clearData(context)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(nIntent)
            } else {
                context.startService(nIntent)
            }
        } catch (e: Exception) {
            return false
        }

        return true
    }

    fun isRunningService(): Boolean = ForegroundService.isRunningService
}
