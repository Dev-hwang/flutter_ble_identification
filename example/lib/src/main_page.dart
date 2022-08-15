import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_ble_identification/flutter_ble_identification.dart';
import 'package:flutter_ble_identification_example/src/log_data.dart';
import 'package:flutter_ble_identification_example/src/service_handler.dart';
import 'package:flutter_dev_framework/flutter_dev_framework.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _editorController = TextEditingController();
  final _scrollController = ScrollController();
  final _lastItemKey = GlobalKey();
  bool _shouldAutoScroll = true;

  final _logDataList = <LogData>[];
  final _logDataListStreamController = StreamController<List<LogData>>();
  final _serviceStatusNotifier = ValueNotifier<bool>(false);

  ReceivePort? _receivePort;
  LogData? _tempLogData;

  Future _initFlutterBleIdentification() async {
    await FlutterBleIdentification.init(
      notificationOptions: NotificationOptions(
        channelId: 'ble_identification_notification',
        channelName: 'BLE 출입증 서비스 알림',
        channelDescription: 'BLE 출입증 서비스가 실행 중일 때 나타나는 알림입니다.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      foregroundServiceOptions: const ForegroundServiceOptions(
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
      bleScannerOptions: const BleScannerOptions(
        serviceUuidFilters: ['6E400001-B5A3-F393-E0A9-E50E24DCCA9E'],
      ),
      printDevLog: true,
    );

    final initLog = LogData.info('서비스 초기화 중');
    _addLogData(initLog);

    if (Platform.isAndroid) {
      if (await FlutterBleIdentification.isSupportedBle) {
        final isEnabledBt = await FlutterBleIdentification.requestEnableBt();
        if (!isEnabledBt) {
          final errorLog = LogData.error('서비스를 이용하려면 블루투스 기능이 활성화되어야 합니다.');
          _addLogData(initLog);
          return Future.error(errorLog.message);
        }
      } else {
        final errorLog = LogData.error('저전력 블루투스를 지원하지 않는 기기입니다.');
        _addLogData(initLog);
        return Future.error(errorLog.message);
      }

      await FlutterBleIdentification.requestIgnoreBatteryOptimization();
    }
  }

  Future _startBleIdentificationService(String authKey) async {
    await _initFlutterBleIdentification();

    ReceivePort? receivePort;
    if (await FlutterBleIdentification.isRunningService) {
      receivePort = await FlutterBleIdentification.restartService();
    } else {
      receivePort = await FlutterBleIdentification.startService(
        notificationTitle: 'BLE 출입증 서비스 실행 중',
        notificationText: '앱으로 돌아가려면 누르세요.',
        authKey: authKey,
        callback: startBleIdentificationServiceHandler,
      );
    }

    if (receivePort != null) {
      final startLog = LogData.info('서비스 시작 요청됨');
      _addLogData(startLog);
      _setServiceStatus(true);

      _receivePort = receivePort;
      _receivePort?.listen((data) {
        if (data is AccessResult) {
          final message = data.toJson().toString();
          _tempLogData = data.resultCode == AccessResultCodes.COMM_SUCCESS
              ? LogData.success(message)
              : LogData.error(message);
        } else if (data is ServiceError) {
          final message = data.toJson().toString();
          _tempLogData = LogData.error(message);
        } else if (data is String) {
          _tempLogData = LogData.info(data);
        }

        if (_tempLogData != null) {
          _addLogData(_tempLogData!);
          _tempLogData = null;
        }
      });
    } else {
      final errorLog = LogData.error('오류가 발생하여 BLE 출입증 서비스를 시작할 수 없습니다.');
      _addLogData(errorLog);
      return Future.error(errorLog.message);
    }
  }

  Future _stopBleIdentificationService() async {
    await FlutterBleIdentification.stopService();

    final stopLog = LogData.info('서비스 중지 요청됨');
    _addLogData(stopLog);
    _setServiceStatus(false);
  }

  void _setServiceStatus(bool status) {
    _serviceStatusNotifier.value = status;
  }

  void _addLogData(LogData logData) {
    if (_logDataList.length > 1000) {
      _logDataList.removeAt(0);
    }

    _logDataList.add(logData);
    _logDataListStreamController.add(_logDataList);

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _shouldAutoScroll) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

        final lastItemKeyContext = _lastItemKey.currentContext;
        if (lastItemKeyContext != null) {
          Scrollable.ensureVisible(lastItemKeyContext);
        }
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      _shouldAutoScroll = true;
    } else {
      _shouldAutoScroll = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // WidgetsBinding.instance?.addPostFrameCallback((_) async {
    //   final isRunningService = await FlutterBleIdentification.isRunningService;
    //   _setServiceStatus(isRunningService);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _stopBleIdentificationService();
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildLogDataListView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 0.0,
      titleSpacing: 0.0,
      automaticallyImplyLeading: false,
      title: TextFormField(
        controller: _editorController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          counterText: '',
          hintText: '전화번호 8자리 (ex. 45671234)',
          hintStyle: TextStyle(color: Colors.white38),
          hintMaxLines: 1,
        ),
        style: const TextStyle(color: Colors.white),
        maxLength: 8,
        maxLines: 1,
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _serviceStatusNotifier,
          builder: (_, value, __) {
            return Switch(
              value: value,
              activeColor: Colors.lightGreen,
              inactiveThumbColor: Theme.of(context).disabledColor,
              trackColor: MaterialStateProperty.all(Colors.white),
              onChanged: (isEnabled) {
                if (isEnabled) {
                  final authKey = _editorController.text;
                  _startBleIdentificationService(authKey);
                } else {
                  _stopBleIdentificationService();
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogDataListView() {
    return StreamBuilder<List<LogData>>(
      stream: _logDataListStreamController.stream,
      initialData: _logDataList,
      builder: (context, snapshot) {
        final dataList = snapshot.data ?? [];

        return Scrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: List.generate(
              dataList.length,
                  (index) {
                return _buildLogDataListItem(
                  dataList[index],
                  dataList.length == index + 1 ? _lastItemKey : null,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogDataListItem(LogData logData, Key? key) {
    String logMessage = logData.message;
    TextStyle? logMessageStyle = Theme.of(context).textTheme.bodyText2;
    if (logData.type == LogType.SUCCESS) {
      logMessage = 'SUCCESS: $logMessage';
      logMessageStyle = logMessageStyle?.copyWith(color: Colors.lightGreen);
    } else if (logData.type == LogType.INFO) {
      logMessage = 'INFO: $logMessage';
    } else {
      logMessage = 'ERROR: $logMessage';
      logMessageStyle = logMessageStyle?.copyWith(color: Colors.redAccent);
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(logData.timestamp,
                  style: Theme.of(context).textTheme.caption),
              const SizedBox(height: 4),
              Text(logMessage, style: logMessageStyle),
            ],
          ),
        ),
        const WidgetDivider(direction: Axis.horizontal),
      ],
    );
  }

  @override
  void dispose() {
    _receivePort?.close();
    _logDataListStreamController.close();
    _serviceStatusNotifier.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _editorController.dispose();
    super.dispose();
  }
}
