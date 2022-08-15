# flutter_ble_identification

GATT를 사용하여 블루투스 신분증 서비스를 구현하는 플러그인 입니다.

## Getting Started

To use this plugin, add `flutter_ble_identification` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  flutter_ble_identification:
    git:
      url: https://github.com/Dev-hwang/flutter_ble_identification.git
      ref: master
```

### :baby_chick: Android

1. `AndroidManifest.xml` 파일을 열고 권한 및 서비스를 설정해주세요.

```xml
<manifest>
    <!-- 권한 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

    <application>
        <!-- 서비스 -->
        <service 
            android:name="com.pravera.flutter_ble_identification.service.ForegroundService"
            android:foregroundServiceType="connectedDevice" 
            android:stopWithTask="true" />
    </application>
</manifest>
```

### :baby_chick: iOS

1. Runner 폴더의 `Info.plist` 파일을 열고 권한 및 모드를 설정해주세요.

```text
<key>NSBluetoothAlwaysUsageDescription</key>
<string>블루투스 출입 인증 장치와 통신하기 위해서 사용됩니다.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>블루투스 출입 인증 장치와 통신하기 위해서 사용됩니다.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>블루투스 출입 인증 장치를 식별하기 위해서 사용됩니다.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>블루투스 출입 인증 장치를 식별하기 위해서 사용됩니다.</string>
<key>NSLocationUsageDescription</key>
<string>블루투스 출입 인증 장치를 식별하기 위해서 사용됩니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>블루투스 출입 인증 장치를 식별하기 위해서 사용됩니다.</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```
