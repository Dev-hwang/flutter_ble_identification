package com.pravera.flutter_ble_identification.service

import android.annotation.SuppressLint
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.pravera.flutter_ble_identification.models.ForegroundServiceOptions
import com.pravera.flutter_ble_identification.models.ForegroundServiceStatus
import com.pravera.flutter_ble_identification.models.NotificationOptions
import com.pravera.flutter_ble_identification.utils.BatteryOptimizationUtils
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import java.util.*
import kotlin.system.exitProcess

private val TAG = ForegroundService::class.java.simpleName
private const val BACKGROUND_CHANNEL_NAME = "flutter_ble_identification/background"
private const val ACTION_BACKGROUND_SERVICE_START = "onStart"
private const val ACTION_ACCESS_SUCCESS = "onAccessSuccess"
private const val ACTION_ACCESS_FAILURE = "onAccessFailure"
private const val ACTION_SCAN_ERROR = "onScanError"
private const val ACTION_GATT_ERROR = "onGattError"
private const val ACTION_GATT_INFO = "onGattInfo"
private const val ACTION_BACKGROUND_SERVICE_DESTROY = "onDestroy"
private const val ACTION_BUTTON_PRESSED = "onButtonPressed"
private const val DATA_FIELD_NAME = "data"

class ForegroundService: Service(), MethodChannel.MethodCallHandler {
    companion object {
        /** Returns whether the foreground service is running. */
        var isRunningService = false
            private set
    }

    private lateinit var foregroundServiceStatus: ForegroundServiceStatus
    private lateinit var foregroundServiceOptions: ForegroundServiceOptions
    private lateinit var notificationOptions: NotificationOptions

    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    private var currFlutterLoader: FlutterLoader? = null
    private var prevFlutterEngine: FlutterEngine? = null
    private var currFlutterEngine: FlutterEngine? = null
    private var backgroundChannel: MethodChannel? = null
    private val bleIdentificationService = BleIdentificationService()

    // A broadcast receiver that handles intents that occur within the foreground service.
    private var broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            try {
                val action = intent?.action ?: return
                val data = intent.getStringExtra(DATA_FIELD_NAME)
                backgroundChannel?.invokeMethod(action, data)
            } catch (e: Exception) {
                Log.e(TAG, "onReceive", e)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        fetchDataFromPreferences()
        registerBroadcastReceiver()

        when (foregroundServiceStatus.action) {
            ForegroundServiceAction.START -> {
                startForegroundService()
                executeDartCallback(foregroundServiceOptions.callbackHandle)
            }
            ForegroundServiceAction.REBOOT -> {
                startForegroundService()
                executeDartCallback(foregroundServiceOptions.callbackHandleOnBoot)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        fetchDataFromPreferences()

        when (foregroundServiceStatus.action) {
            ForegroundServiceAction.UPDATE -> {
                startForegroundService()
                executeDartCallback(foregroundServiceOptions.callbackHandle)
            }
            ForegroundServiceAction.RESTART -> {
                startForegroundService()
                executeDartCallback(foregroundServiceOptions.callbackHandleOnBoot)
            }
            ForegroundServiceAction.STOP -> {
                stopForegroundService()
                return START_NOT_STICKY
            }
        }

        return if (notificationOptions.isSticky) START_STICKY else START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        releaseLockMode()
        destroyBackgroundService()
        unregisterBroadcastReceiver()
        if (!isSetStopWithTaskFlag() && foregroundServiceStatus.action != ForegroundServiceAction.STOP) {
            Log.i(TAG, "The foreground service was terminated due to an unexpected problem.")
            if (notificationOptions.isSticky) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (!BatteryOptimizationUtils.isIgnoringBatteryOptimizations(applicationContext)) {
                        Log.i(TAG, "Turn off battery optimization to restart service in the background.")
                        return
                    }
                }

                setRestartAlarm()
            } else {
                exitProcess(0)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startBackgroundService" -> startBackgroundService()
            else -> result.notImplemented()
        }
    }

    private fun fetchDataFromPreferences() {
        foregroundServiceStatus = ForegroundServiceStatus.getData(applicationContext)
        foregroundServiceOptions = ForegroundServiceOptions.getData(applicationContext)
        notificationOptions = NotificationOptions.getData(applicationContext)
    }

    private fun registerBroadcastReceiver() {
        val intentFilter = IntentFilter().apply {
            addAction(ACTION_BUTTON_PRESSED)
        }
        registerReceiver(broadcastReceiver, intentFilter)
    }

    private fun unregisterBroadcastReceiver() {
        unregisterReceiver(broadcastReceiver)
    }

    @SuppressLint("WrongConstant")
    private fun startForegroundService() {
        // Get the icon and PendingIntent to put in the notification.
        val pm = applicationContext.packageManager
        val icResType = notificationOptions.iconData?.resType
        val icResPrefix = notificationOptions.iconData?.resPrefix
        val icName = notificationOptions.iconData?.name
        val icResId = if (icResType.isNullOrEmpty()
            || icResPrefix.isNullOrEmpty()
            || icName.isNullOrEmpty()) {
            getAppIconResourceId(pm)
        } else {
            getDrawableResourceId(icResType, icResPrefix, icName)
        }
        val pendingIntent = getPendingIntent(pm)

        // Create a notification and start the foreground service.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                notificationOptions.channelId,
                notificationOptions.channelName,
                notificationOptions.channelImportance)
            channel.description = notificationOptions.channelDescription
            channel.enableVibration(notificationOptions.enableVibration)
            channel.setShowBadge(false)
            if (!notificationOptions.playSound) {
                channel.setSound(null, null)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)

            val builder = Notification.Builder(this, notificationOptions.channelId)
            builder.setOngoing(true)
            builder.setShowWhen(notificationOptions.showWhen)
            builder.setSmallIcon(icResId)
            builder.setContentIntent(pendingIntent)
            builder.setContentTitle(notificationOptions.contentTitle)
            builder.setContentText(notificationOptions.contentText)
            builder.setVisibility(notificationOptions.visibility)
            for (action in buildNotificationActions()) {
                builder.addAction(action)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
            }
            startForeground(notificationOptions.serviceId, builder.build())
        } else {
            val builder = NotificationCompat.Builder(this, notificationOptions.channelId)
            builder.setOngoing(true)
            builder.setShowWhen(notificationOptions.showWhen)
            builder.setSmallIcon(icResId)
            builder.setContentIntent(pendingIntent)
            builder.setContentTitle(notificationOptions.contentTitle)
            builder.setContentText(notificationOptions.contentText)
            builder.setVisibility(notificationOptions.visibility)
            if (!notificationOptions.enableVibration) { builder.setVibrate(longArrayOf(0L)) }
            if (!notificationOptions.playSound) { builder.setSound(null) }
            builder.priority = notificationOptions.priority
            for (action in buildNotificationCompatActions()) {
                builder.addAction(action)
            }
            startForeground(notificationOptions.serviceId, builder.build())
        }

        acquireLockMode()
        isRunningService = true
    }

    private fun stopForegroundService() {
        releaseLockMode()
        stopForeground(true)
        stopSelf()
        isRunningService = false
    }

    private fun executeDartCallback(callbackHandle: Long?) {
        // If there is no callback handle, the code below will not be executed.
        if (callbackHandle == null) return

        initBackgroundService()

        val bundlePath = currFlutterLoader?.findAppBundlePath() ?: return
        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        val dartCallback = DartExecutor.DartCallback(assets, bundlePath, callbackInfo)
        currFlutterEngine?.dartExecutor?.executeDartCallback(dartCallback)
    }

    private fun initBackgroundService() {
        if (currFlutterEngine != null) destroyBackgroundService()

        currFlutterEngine = FlutterEngine(this)

        currFlutterLoader = FlutterInjector.instance().flutterLoader()
        currFlutterLoader?.startInitialization(this)
        currFlutterLoader?.ensureInitializationComplete(this, null)

        val messenger = currFlutterEngine?.dartExecutor?.binaryMessenger ?: return
        backgroundChannel = MethodChannel(messenger, BACKGROUND_CHANNEL_NAME)
        backgroundChannel?.setMethodCallHandler(this)
    }

    private fun startBackgroundService() {
        stopBackgroundService()

        val mCallback = object : MethodChannel.Result {
            override fun success(result: Any?) {
                bleIdentificationService.start(
                    context = applicationContext,
                    callback = object : BleIdentificationServiceCallback {
                        private val handler = Handler(Looper.getMainLooper())

                        override fun onAccessSuccess(resultCode: String) {
                            handler.post {
                                backgroundChannel?.invokeMethod(ACTION_ACCESS_SUCCESS, resultCode)
                            }
                        }

                        override fun onAccessFailure(resultCode: String) {
                            handler.post {
                                backgroundChannel?.invokeMethod(ACTION_ACCESS_FAILURE, resultCode)
                            }
                        }

                        override fun onScanError(errorJson: String) {
                            handler.post {
                                backgroundChannel?.invokeMethod(ACTION_SCAN_ERROR, errorJson)
                            }
                        }

                        override fun onGattError(errorJson: String) {
                            handler.post {
                                backgroundChannel?.invokeMethod(ACTION_GATT_ERROR, errorJson)
                            }
                        }

                        override fun onGattInfo(message: String) {
                            handler.post {
                                backgroundChannel?.invokeMethod(ACTION_GATT_INFO, message)
                            }
                        }
                    }
                )
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) { }

            override fun notImplemented() { }
        }
        backgroundChannel?.invokeMethod(ACTION_BACKGROUND_SERVICE_START, null, mCallback)
    }

    private fun stopBackgroundService() {
        bleIdentificationService.stop()
    }

    private fun destroyBackgroundService() {
        stopBackgroundService()

        currFlutterLoader = null
        prevFlutterEngine = currFlutterEngine
        currFlutterEngine = null

        val mCallback = object : MethodChannel.Result {
            override fun success(result: Any?) {
                prevFlutterEngine?.destroy()
                prevFlutterEngine = null
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                prevFlutterEngine?.destroy()
                prevFlutterEngine = null
            }

            override fun notImplemented() {
                prevFlutterEngine?.destroy()
                prevFlutterEngine = null
            }
        }
        backgroundChannel?.invokeMethod(ACTION_BACKGROUND_SERVICE_DESTROY, null, mCallback)
        backgroundChannel?.setMethodCallHandler(null)
        backgroundChannel = null
    }

    @SuppressLint("WakelockTimeout")
    private fun acquireLockMode() {
        if (wakeLock == null || wakeLock?.isHeld == false) {
            wakeLock = (applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager).run {
                newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "ForegroundService:WakeLock").apply {
                    setReferenceCounted(false)
                    acquire()
                }
            }
        }

        if (foregroundServiceOptions.allowWifiLock && (wifiLock == null || wifiLock?.isHeld == false)) {
            wifiLock = (applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager).run {
                createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "ForegroundService:WifiLock").apply {
                    setReferenceCounted(false)
                    acquire()
                }
            }
        }
    }

    private fun releaseLockMode() {
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }

        wifiLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
    }

    private fun setRestartAlarm() {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            add(Calendar.SECOND, 1)
        }

        val intent = Intent(this, RestartReceiver::class.java)
        val sender = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getBroadcast(this, 0, intent, 0)
        }

        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, sender)
    }

    private fun isSetStopWithTaskFlag(): Boolean {
        val pm = applicationContext.packageManager
        val cName = ComponentName(this, this.javaClass)
        val flags = pm.getServiceInfo(cName, PackageManager.GET_META_DATA).flags

        return flags > 0
    }

    private fun getDrawableResourceId(resType: String, resPrefix: String, name: String): Int {
        val resName = if (resPrefix.contains("ic")) {
            String.format("ic_%s", name)
        } else {
            String.format("img_%s", name)
        }

        return applicationContext.resources.getIdentifier(resName, resType, applicationContext.packageName)
    }

    private fun getAppIconResourceId(pm: PackageManager): Int {
        return try {
            val appInfo = pm.getApplicationInfo(applicationContext.packageName, PackageManager.GET_META_DATA)
            appInfo.icon
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e(TAG, "getAppIconResourceId", e)
            0
        }
    }

    private fun getPendingIntent(pm: PackageManager): PendingIntent {
        val launchIntent = pm.getLaunchIntentForPackage(applicationContext.packageName)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.getActivity(this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getActivity(this, 0, launchIntent, 0)
        }
    }

    private fun buildNotificationActions(): List<Notification.Action> {
        val actions = mutableListOf<Notification.Action>()
        val buttons = notificationOptions.buttons
        for (i in buttons.indices) {
            val bIntent = Intent(ACTION_BUTTON_PRESSED).apply {
                putExtra(DATA_FIELD_NAME, buttons[i].id)
            }
            val bPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.getBroadcast(this, i + 1, bIntent, PendingIntent.FLAG_IMMUTABLE)
            } else {
                PendingIntent.getBroadcast(this, i + 1, bIntent, 0)
            }
            val bAction = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Notification.Action.Builder(null, buttons[i].text, bPendingIntent).build()
            } else {
                Notification.Action.Builder(0, buttons[i].text, bPendingIntent).build()
            }
            actions.add(bAction)
        }

        return actions
    }

    private fun buildNotificationCompatActions(): List<NotificationCompat.Action> {
        val actions = mutableListOf<NotificationCompat.Action>()
        val buttons = notificationOptions.buttons
        for (i in buttons.indices) {
            val bIntent = Intent(ACTION_BUTTON_PRESSED).apply {
                putExtra(DATA_FIELD_NAME, buttons[i].id)
            }
            val bPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.getBroadcast(this, i + 1, bIntent, PendingIntent.FLAG_IMMUTABLE)
            } else {
                PendingIntent.getBroadcast(this, i + 1, bIntent, 0)
            }
            val bAction = NotificationCompat.Action.Builder(0, buttons[i].text, bPendingIntent).build()
            actions.add(bAction)
        }

        return actions
    }
}
