import Flutter
import UIKit

public class SwiftFlutterBleIdentificationPlugin: NSObject, FlutterPlugin {
  static private(set) var registerPlugins: FlutterPluginRegistrantCallback? = nil
  
  private var backgroundServiceManager: BackgroundServiceManager? = nil
  private var foregroundChannel: FlutterMethodChannel? = nil
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftFlutterBleIdentificationPlugin()
    instance.initServices()
    instance.initChannels(registrar.messenger())
    registrar.addApplicationDelegate(instance)
  }
  
  public static func setPluginRegistrantCallback(_ callback: @escaping FlutterPluginRegistrantCallback) {
    registerPlugins = callback
  }
  
  private func initServices() {
    backgroundServiceManager = BackgroundServiceManager()
  }
  
  private func initChannels(_ messenger: FlutterBinaryMessenger) {
    foregroundChannel = FlutterMethodChannel(name: "flutter_ble_identification/method", binaryMessenger: messenger)
    foregroundChannel?.setMethodCallHandler(onMethodCall)
  }
  
  private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "startForegroundService":
        result(backgroundServiceManager?.start(call: call) ?? false)
      case "restartForegroundService":
        result(backgroundServiceManager?.restart(call: call) ?? false)
      case "updateForegroundService":
        result(backgroundServiceManager?.update(call: call) ?? false)
      case "stopForegroundService":
        result(backgroundServiceManager?.stop() ?? false)
      case "isRunningService":
        result(backgroundServiceManager?.isRunningService() ?? false)
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
