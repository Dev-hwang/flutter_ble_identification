import 'package:flutter/material.dart';
import 'package:flutter_ble_identification_example/src/main_page.dart';
import 'package:flutter_dev_framework/flutter_dev_framework.dart';

const List<PermissionData> kAppPermissions = [
  PermissionData(
    permissionType: PermissionType.LOCATION_ALWAYS,
    description: '백그라운드에서 출입 인증 장치를 검색하기 위해서 사용됩니다.',
    isNecessary: true,
  ),
  PermissionData(
    permissionType: PermissionType.BLUETOOTH,
    description: '출입 인증 장치를 제어하기 위해서 사용됩니다.',
    isNecessary: true,
  ),
  PermissionData(
    permissionType: PermissionType.BLUETOOTH_SCAN,
    description: '출입 인증 장치를 검색하기 위해서 사용됩니다.',
    isNecessary: true,
  ),
  PermissionData(
    permissionType: PermissionType.BLUETOOTH_CONNECT,
    description: '출입 입증 장치와 통신하기 위해서 사용됩니다.',
    isNecessary: true,
  ),
];

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<InitResult> _initFunction() async {
    InitResult initResult;
    try {
      initResult = const InitResult(complete: true);
    } catch (error, stackTrace) {
      initResult = InitResult(
        complete: false,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return initResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PermissionCheckPage(
        permissions: kAppPermissions,
        appIconAssetsPath: 'assets/images/ic_launcher.png',
        requestMessageColor: Theme.of(context).textTheme.headline6?.color,
        permissionIconColor: Theme.of(context).textTheme.subtitle1?.color,
        permissionNameColor: Theme.of(context).textTheme.subtitle1?.color,
        permissionDescColor: Theme.of(context).textTheme.bodyText2?.color,
        initFunction: _initFunction,
        nextPage: const MainPage(),
      ),
    );
  }
}
