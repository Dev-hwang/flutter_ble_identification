package com.pravera.flutter_ble_identification.errors

import com.google.gson.annotations.SerializedName

data class ServiceError(
    @SerializedName("errorCode") val errorCode: String,
    @SerializedName("errorMessage") val errorMessage: String)
