package com.pravera.flutter_ble_identification.service

import android.bluetooth.*
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.os.Build
import com.google.gson.Gson
import com.pravera.flutter_ble_identification.errors.ServiceErrorCodes
import com.pravera.flutter_ble_identification.errors.ServiceError
import com.pravera.flutter_ble_identification.models.AccessResult
import com.pravera.flutter_ble_identification.models.AccessResultCodes
import com.pravera.flutter_ble_identification.models.BleIdentificationData
import com.pravera.flutter_ble_identification.models.BleScannerOptions
import com.pravera.flutter_ble_identification.utils.BleIdentificationServiceUtils
import com.pravera.flutter_ble_identification.utils.BytesUtils
import kotlinx.coroutines.*
import java.util.*

private const val BLE_SCANNER_RESTART_INTERVAL = 10 * 1000L
private const val DISCOVERY_JOB_DELAY = 60 * 1000L
private const val ACCESS_USER_DELAY = 1 * 1000L
private const val ACCESS_USER_TIMEOUT = 3 * 1000L

private const val UART_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
private const val RX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
private const val TX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
private const val CCC_UUID = "00002902-0000-1000-8000-00805F9B34FB"

class BleIdentificationService {
    private var context: Context? = null
    private var callback: BleIdentificationServiceCallback? = null
    private var bleScannerOptions: BleScannerOptions? = null
    private var bleIdentificationData: BleIdentificationData? = null

    private var bleAdapter: BluetoothAdapter? = null
    private var bleGattDict: MutableMap<String, BluetoothGatt> = mutableMapOf()
    private var timeoutJobs: MutableMap<String, Job> = mutableMapOf()

    private var discoveryJob: Job? = null
    private var scanStartJob: Job? = null
    private var scanStoppedTimeMillis: Long = 0L
    private var isScanning = false

    private val jsonEncoder = Gson()

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            if (result == null) return
            connectGatt(result)
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            super.onBatchScanResults(results)
            if (results == null) return
            results.forEach { connectGatt(it) }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            val error = ServiceErrorCodes.fromScanErrorCode(errorCode).toModel()
            onScanError(error)
        }
    }

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            super.onConnectionStateChange(gatt, status, newState)
            val address = gatt?.device?.address ?: return
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    onGattInfo("Connected to [$address].")
                    gatt.discoverServices()
                }
                BluetoothProfile.STATE_DISCONNECTED -> {
                    onGattInfo("Disconnected from [$address], status: $status")
                    disconnectGatt(gatt)
                }
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            super.onServicesDiscovered(gatt, status)
            val address = gatt?.device?.address ?: return
            when (status) {
                BluetoothGatt.GATT_SUCCESS -> {
                    onGattInfo("[$address] Found Nordic UART service.")

                    val rxCharacteristic = getRxCharacteristic(gatt)
                    val txCharacteristic = getTxCharacteristic(gatt)
                    if (rxCharacteristic != null && txCharacteristic != null) {
                        onGattInfo("[$address] Found WRITE/NOTIFY properties.")

                        gatt.setCharacteristicNotification(rxCharacteristic, true)
                        val descriptor = getClientCharConfig(rxCharacteristic)
                        if (descriptor != null) {
                            descriptor.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                            if (gatt.writeDescriptor(descriptor)) {
                                accessUser(gatt, address)
                            } else {
                                onGattInfo("[$address] Failed to write notification enable descriptor.")
                                disconnectGatt(gatt)
                            }
                        } else {
                            onGattInfo("[$address] Not found client characteristic configuration.")
                            disconnectGatt(gatt)
                        }
                    } else {
                        onGattInfo("[$address] Not found properties for UART communication.")
                        disconnectGatt(gatt)
                    }
                }
                else -> {
                    onGattInfo("[$address] Service discovery failure, status: $status")
                    disconnectGatt(gatt)
                }
            }
        }

        override fun onCharacteristicChanged(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?
        ) {
            super.onCharacteristicChanged(gatt, characteristic)
            val address = gatt?.device?.address ?: return
            readCharacteristic(characteristic, address)
            disconnectGatt(gatt)
        }

        override fun onCharacteristicWrite(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            super.onCharacteristicWrite(gatt, characteristic, status)
            val address = gatt?.device?.address ?: return
            when (status) {
                BluetoothGatt.GATT_SUCCESS -> {
                    val hexStr = characteristic?.value?.let { BytesUtils.bytesToHexString(it, " ") }
                    onGattInfo("[$address] onCharacteristicWrite() - $hexStr")

                    timeoutJobs[address] = GlobalScope.launch {
                        delay(ACCESS_USER_TIMEOUT)

                        onGattError(
                            ServiceErrorCodes.ACCESS_USER_TIMEOUT
                                .toModel("[$address] 출입 인증 요청 응답시간이 초과되었습니다.")
                        )

                        disconnectGatt(gatt)
                    }
                }
                else -> {
                    onGattError(
                        ServiceErrorCodes.WRITE_CHARACTERISTIC_FAILED
                            .toModel("[$address] Failed to write characteristic, status: $status")
                    )

                    disconnectGatt(gatt)
                }
            }
        }

        override fun onCharacteristicRead(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            super.onCharacteristicRead(gatt, characteristic, status)
            val address = gatt?.device?.address ?: return
            when (status) {
                BluetoothGatt.GATT_SUCCESS -> {
                    readCharacteristic(characteristic, address)
                    disconnectGatt(gatt)
                }
                else -> {
                    onGattError(
                        ServiceErrorCodes.READ_CHARACTERISTIC_FAILED
                            .toModel("[$address] Failed to read characteristic, status: $status")
                    )

                    disconnectGatt(gatt)
                }
            }
        }

        private fun getGattService(gatt: BluetoothGatt?, uuid: UUID): BluetoothGattService? {
            return gatt?.getService(uuid)
        }

        private fun getRxCharacteristic(gatt: BluetoothGatt?): BluetoothGattCharacteristic? {
            val uartService = getGattService(gatt, UUID.fromString(UART_UUID))
            return uartService?.getCharacteristic(UUID.fromString(RX_CHAR_UUID))
        }

        private fun getTxCharacteristic(gatt: BluetoothGatt?): BluetoothGattCharacteristic? {
            val uartService = getGattService(gatt, UUID.fromString(UART_UUID))
            return uartService?.getCharacteristic(UUID.fromString(TX_CHAR_UUID))
        }

        private fun getClientCharConfig(char: BluetoothGattCharacteristic?): BluetoothGattDescriptor? {
            return char?.getDescriptor(UUID.fromString(CCC_UUID))
        }

        private fun readCharacteristic(char: BluetoothGattCharacteristic?, address: String) {
            val responseBytes = char?.value
            val hexStr = responseBytes?.let { BytesUtils.bytesToHexString(it, " ") }
            onGattInfo("[$address] onCharacteristicRead() - $hexStr")

            if (responseBytes != null && responseBytes.size >= 8) {
                val result = AccessResultCodes.fromByte(responseBytes[4]).toModel()
                onAccessResult(result)
            }
        }

        private fun accessUser(gatt: BluetoothGatt, address: String) {
            GlobalScope.launch {
                delay(ACCESS_USER_DELAY)

                try {
                    val txChar = getTxCharacteristic(gatt)
                    if (txChar != null) {
                        val authKey = bleIdentificationData?.authKey ?: ""
                        txChar.value =
                            BleIdentificationServiceUtils.generateUserAccessPacket(authKey)
                        gatt.writeCharacteristic(txChar)
                        onGattInfo("[$address] 출입 인증 요청에 성공하였습니다.")
                    } else {
                        throw Exception()
                    }
                } catch (_: Exception) {
                    onGattError(
                        ServiceErrorCodes.ACCESS_USER_FAILED
                            .toModel("[$address] 출입 인증 요청에 실패하였습니다.")
                    )

                    disconnectGatt(gatt)
                }
            }
        }
    }

    fun start(context: Context, callback: BleIdentificationServiceCallback) {
        this.context = context
        this.callback = callback
        this.bleScannerOptions = BleScannerOptions.getData(context)
        this.bleIdentificationData = BleIdentificationData.getData(context)

        val bleManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bleAdapter = bleManager.adapter

        startScan()
    }

    fun stop() {
        clearBleGattDict()
        clearTimeoutJobs()
        stopScan()

        context = null
        callback = null
        bleScannerOptions = null
        bleIdentificationData = null
        bleAdapter = null
    }

    private fun startScan() {
        stopScan()

        val currTimeMillis = System.currentTimeMillis()
        val diffTimeMillis = currTimeMillis - scanStoppedTimeMillis
        val jobDelay =
            if (scanStoppedTimeMillis == 0L || diffTimeMillis >= BLE_SCANNER_RESTART_INTERVAL) {
                1000
            } else {
                BLE_SCANNER_RESTART_INTERVAL - diffTimeMillis
            }

        scanStartJob = GlobalScope.launch {
            delay(jobDelay)

            val scanFilters = bleScannerOptions?.getScanFilters()
            val scanSettings = bleScannerOptions?.getScanSettings()
            bleAdapter?.bluetoothLeScanner?.startScan(scanFilters, scanSettings, scanCallback)
            launchDiscoveryJob()
            isScanning = true
        }
    }

    private fun stopScan() {
        scanStartJob?.cancel()
        scanStartJob = null

        if (isScanning) {
            cancelDiscoveryJob()
            bleAdapter?.bluetoothLeScanner?.stopScan(scanCallback)
            scanStoppedTimeMillis = System.currentTimeMillis()
            isScanning = false
        }
    }

    private fun launchDiscoveryJob() {
        if (discoveryJob != null) {
            cancelDiscoveryJob()
        }

        discoveryJob = GlobalScope.launch {
            while (isActive) {
                bleAdapter?.cancelDiscovery()
                bleAdapter?.startDiscovery()
                delay(DISCOVERY_JOB_DELAY)
            }
        }
    }

    private fun cancelDiscoveryJob() {
        discoveryJob?.cancel()
        discoveryJob = null
        bleAdapter?.cancelDiscovery()
    }

    private fun clearBleGattDict() {
        bleGattDict.values.forEach {
            it.disconnect()
            it.close()
        }
        bleGattDict.clear()
    }

    private fun clearTimeoutJobs() {
        timeoutJobs.values.forEach {
            it.cancel()
        }
        timeoutJobs.clear()
    }

    private fun connectGatt(result: ScanResult) {
        // 서비스가 시작되지 않은 경우
        if (context == null) return

        val address = result.device?.address ?: return
        val rssi = result.rssi

        // 디바이스에 연결 요청 중이거나 BLE 통신 중인 경우
        if (bleGattDict.containsKey(address)) return

        // 수신 감도가 -70dBm 보다 나쁜 경우
        if (rssi > 0 || rssi < -70) {
            onGattInfo("[$address] Bad RSSI: $rssi")
            return
        }

        stopScan()

        val bleGatt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            result.device.connectGatt(context, false, gattCallback, BluetoothDevice.TRANSPORT_LE)
        } else {
            result.device.connectGatt(context, false, gattCallback)
        }
        bleGattDict[address] = bleGatt
    }

    private fun disconnectGatt(gatt: BluetoothGatt) {
        gatt.disconnect()
        gatt.close()

        val address = gatt.device?.address ?: ""
        if (address.isNotEmpty()) {
            timeoutJobs[address]?.cancel()
            timeoutJobs.remove(address)
            bleGattDict.remove(address)
        }

        if (bleGattDict.isEmpty()) {
            startScan()
        }
    }

    private fun onAccessResult(result: AccessResult) {
        if (AccessResultCodes.valueOf(result.resultCode) == AccessResultCodes.COMM_SUCCESS) {
            callback?.onAccessSuccess(jsonEncoder.toJson(result))
        } else {
            callback?.onAccessFailure(jsonEncoder.toJson(result))
        }
    }

    private fun onScanError(error: ServiceError) {
        callback?.onScanError(jsonEncoder.toJson(error))
    }

    private fun onGattError(error: ServiceError) {
        callback?.onGattError(jsonEncoder.toJson(error))
    }

    private fun onGattInfo(message: String) {
        callback?.onGattInfo(message)
    }
}
