/* flutter_ble_identification 플러그인 사용 예제입니다. */

import 'package:flutter/material.dart';
import 'package:flutter_ble_identification_example/app_theme.dart';
import 'package:flutter_ble_identification_example/src/splash_page.dart';
import 'package:flutter_dev_framework/flutter_dev_framework.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WithThemeManager(
      themeData: AppTheme.light,
      builder: (context, themeData) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: const SplashPage(),
        );
      },
    );
  }
}
