package com.pravera.flutter_ble_identification.utils

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

class BluetoothUtils {
    companion object {
        fun isSupportedBle(context: Context): Boolean {
            val pm = context.packageManager
            return pm.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
        }

        fun isSupportedBt(context: Context): Boolean {
            val pm = context.packageManager
            return pm.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH)
        }

        fun isEnabledBt(context: Context): Boolean {
            val bm = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            return bm.adapter.isEnabled
        }

        fun requestEnableBt(activity: Activity?, recCode: Int): Boolean {
            if (activity == null) return false

            val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_CONNECT)
            } else {
                PackageManager.PERMISSION_GRANTED
            }

            if (permission == PackageManager.PERMISSION_GRANTED) {
                val nIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                activity.startActivityForResult(nIntent, recCode)
                return true
            }

            return false
        }
    }
}
