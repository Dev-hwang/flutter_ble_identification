#import "FlutterBleIdentificationPlugin.h"
#if __has_include(<flutter_ble_identification/flutter_ble_identification-Swift.h>)
#import <flutter_ble_identification/flutter_ble_identification-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_ble_identification-Swift.h"
#endif

@implementation FlutterBleIdentificationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBleIdentificationPlugin registerWithRegistrar:registrar];
}
@end
