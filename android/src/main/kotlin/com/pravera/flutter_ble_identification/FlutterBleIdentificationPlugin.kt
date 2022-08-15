package com.pravera.flutter_ble_identification

import androidx.annotation.NonNull
import com.pravera.flutter_ble_identification.service.ForegroundServiceManager
import com.pravera.flutter_ble_identification.service.ServiceProvider

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterBleIdentificationPlugin */
class FlutterBleIdentificationPlugin: FlutterPlugin, ActivityAware, ServiceProvider {
  private var activityBinding: ActivityPluginBinding? = null
  private lateinit var methodCallHandler: MethodCallHandlerImpl

  private val foregroundServiceManager = ForegroundServiceManager()

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodCallHandler = MethodCallHandlerImpl(binding.applicationContext, this)
    methodCallHandler.init(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (::methodCallHandler.isInitialized) {
      methodCallHandler.dispose()
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    methodCallHandler.setActivity(binding.activity)

    binding.addActivityResultListener(methodCallHandler)
    activityBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    methodCallHandler.setActivity(null)

    activityBinding?.removeActivityResultListener(methodCallHandler)
    activityBinding = null
  }

  override fun getForegroundServiceManager() = foregroundServiceManager
}
