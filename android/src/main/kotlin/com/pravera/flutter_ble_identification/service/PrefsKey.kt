package com.pravera.flutter_ble_identification.service

object PrefsKey {
    private const val prefix = "com.pravera.flutter_ble_identification.prefs."

    const val SERVICE_OPTIONS_PREFS_NAME = prefix + "SERVICE_OPTIONS"
    const val AUTO_RUN_ON_BOOT = "autoRunOnBoot"
    const val ALLOW_WIFI_LOCK = "allowWifiLock"
    const val CALLBACK_HANDLE = "callbackHandle"
    const val CALLBACK_HANDLE_ON_BOOT = "callbackHandleOnBoot"

    const val SERVICE_STATUS_PREFS_NAME = prefix + "SERVICE_STATUS"
    const val SERVICE_ACTION = "serviceAction"

    const val NOTIFICATION_OPTIONS_PREFS_NAME = prefix + "NOTIFICATION_OPTIONS"
    const val NOTIFICATION_CHANNEL_ID = "notificationChannelId"
    const val NOTIFICATION_CHANNEL_NAME = "notificationChannelName"
    const val NOTIFICATION_CHANNEL_DESC = "notificationChannelDescription"
    const val NOTIFICATION_CHANNEL_IMPORTANCE = "notificationChannelImportance"
    const val NOTIFICATION_PRIORITY = "notificationPriority"
    const val NOTIFICATION_CONTENT_TITLE = "notificationContentTitle"
    const val NOTIFICATION_CONTENT_TEXT = "notificationContentText"
    const val ENABLE_VIBRATION = "enableVibration"
    const val PLAY_SOUND = "playSound"
    const val SHOW_WHEN = "showWhen"
    const val IS_STICKY = "isSticky"
    const val VISIBILITY = "visibility"
    const val ICON_DATA = "iconData"
    const val BUTTONS = "buttons"

    const val BLE_SCANNER_OPTIONS_PREFS_NAME = prefix + "BLE_SCANNER_OPTIONS"
    const val DEVICE_ADDRESS_FILTERS = "deviceAddressFilters"
    const val DEVICE_NAME_FILTERS = "deviceNameFilters"
    const val SERVICE_UUID_FILTERS = "serviceUuidFilters"
    const val SCAN_MODE = "scanMode"
    const val REPORT_DELAY = "reportDelay"

    const val BLE_IDENTIFICATION_DATA_PREFS_NAME = prefix + "BLE_IDENTIFICATION_DATA"
    const val AUTH_KEY = "authKey"
}
