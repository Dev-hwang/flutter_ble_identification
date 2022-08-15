package com.pravera.flutter_ble_identification.service

object ForegroundServiceAction {
	private const val prefix = "com.pravera.flutter_ble_identification.action."
	const val START = prefix + "start"
	const val UPDATE = prefix + "update"
	const val REBOOT = prefix + "reboot"
	const val RESTART = prefix + "restart"
	const val STOP = prefix + "stop"
}
