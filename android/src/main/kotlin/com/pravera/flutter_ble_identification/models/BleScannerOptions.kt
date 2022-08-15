package com.pravera.flutter_ble_identification.models

import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.ParcelUuid
import com.pravera.flutter_ble_identification.service.PrefsKey
import org.json.JSONArray

data class BleScannerOptions(
    val deviceAddressFilters: List<String>,
    val deviceNameFilters: List<String>,
    val serviceUuidFilters: List<String>,
    val scanMode: Int,
    val reportDelay: Long
    ) {
    companion object {
        fun putData(context: Context, map: Map<*, *>?) {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_SCANNER_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            val deviceAddressFilters = map?.get(PrefsKey.DEVICE_ADDRESS_FILTERS) as? List<*>
            var deviceAddressFiltersJson: String? = null
            if (deviceAddressFilters != null) {
                deviceAddressFiltersJson = JSONArray(deviceAddressFilters).toString()
            }

            val deviceNameFilters = map?.get(PrefsKey.DEVICE_NAME_FILTERS) as? List<*>
            var deviceNameFiltersJson: String? = null
            if (deviceNameFilters != null) {
                deviceNameFiltersJson = JSONArray(deviceNameFilters).toString()
            }

            val serviceUuidFilters = map?.get(PrefsKey.SERVICE_UUID_FILTERS) as? List<*>
            var serviceUuidFiltersJson: String? = null
            if (serviceUuidFilters != null) {
                serviceUuidFiltersJson = JSONArray(serviceUuidFilters).toString()
            }

            val scanMode = "${map?.get(PrefsKey.SCAN_MODE)}".toIntOrNull() ?: 0
            val reportDelay = "${map?.get(PrefsKey.REPORT_DELAY)}".toLongOrNull() ?: 0L

            with (prefs.edit()) {
                putString(PrefsKey.DEVICE_ADDRESS_FILTERS, deviceAddressFiltersJson)
                putString(PrefsKey.DEVICE_NAME_FILTERS, deviceNameFiltersJson)
                putString(PrefsKey.SERVICE_UUID_FILTERS, serviceUuidFiltersJson)
                putInt(PrefsKey.SCAN_MODE, scanMode)
                putLong(PrefsKey.REPORT_DELAY, reportDelay)
                commit()
            }
        }

        fun getData(context: Context): BleScannerOptions {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_SCANNER_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            val deviceAddressFiltersJson = prefs.getString(PrefsKey.DEVICE_ADDRESS_FILTERS, null)
            val deviceAddressFilters: MutableList<String> = mutableListOf()
            if (deviceAddressFiltersJson != null) {
                val jsonArr = JSONArray(deviceAddressFiltersJson)
                for (i in 0 until jsonArr.length()) {
                    val jsonObj = jsonArr.optString(i)
                    deviceAddressFilters.add(jsonObj)
                }
            }

            val deviceNameFiltersJson = prefs.getString(PrefsKey.DEVICE_NAME_FILTERS, null)
            val deviceNameFilters: MutableList<String> = mutableListOf()
            if (deviceNameFiltersJson != null) {
                val jsonArr = JSONArray(deviceNameFiltersJson)
                for (i in 0 until jsonArr.length()) {
                    val jsonObj = jsonArr.optString(i)
                    deviceNameFilters.add(jsonObj)
                }
            }

            val serviceUuidFiltersJson = prefs.getString(PrefsKey.SERVICE_UUID_FILTERS, null)
            val serviceUuidFilters: MutableList<String> = mutableListOf()
            if (serviceUuidFiltersJson != null) {
                val jsonArr = JSONArray(serviceUuidFiltersJson)
                for (i in 0 until jsonArr.length()) {
                    val jsonObj = jsonArr.optString(i)
                    serviceUuidFilters.add(jsonObj)
                }
            }

            val scanMode = prefs.getInt(PrefsKey.SCAN_MODE, 0)
            val reportDelay = prefs.getLong(PrefsKey.REPORT_DELAY, 0L)

            return BleScannerOptions(
                deviceAddressFilters = deviceAddressFilters,
                deviceNameFilters = deviceNameFilters,
                serviceUuidFilters = serviceUuidFilters,
                scanMode = scanMode,
                reportDelay = reportDelay
            )
        }

        fun clearData(context: Context) {
            val prefs = context.getSharedPreferences(
                PrefsKey.BLE_SCANNER_OPTIONS_PREFS_NAME, Context.MODE_PRIVATE)

            with (prefs.edit()) {
                clear()
                commit()
            }
        }
    }

    fun getScanFilters(): List<ScanFilter> {
        val scanFilters = mutableListOf<ScanFilter>()
        var scanFilter: ScanFilter? = null
        deviceAddressFilters.forEach {
            scanFilter = ScanFilter.Builder().setDeviceAddress(it).build()
            scanFilters.add(scanFilter!!)
        }
        deviceNameFilters.forEach {
            scanFilter = ScanFilter.Builder().setDeviceName(it).build()
            scanFilters.add(scanFilter!!)
        }
        serviceUuidFilters.forEach {
            scanFilter = ScanFilter.Builder().setServiceUuid(ParcelUuid.fromString(it)).build()
            scanFilters.add(scanFilter!!)
        }

        return scanFilters
    }

    fun getScanSettings(): ScanSettings {
        return ScanSettings.Builder()
            .setScanMode(scanMode)
            .setReportDelay(reportDelay)
            .build()
    }
}
