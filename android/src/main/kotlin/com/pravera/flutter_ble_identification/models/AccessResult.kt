package com.pravera.flutter_ble_identification.models

import com.google.gson.annotations.SerializedName

data class AccessResult(
    @SerializedName("resultCode") val resultCode: String,
    @SerializedName("resultMessage") val resultMessage: String)
