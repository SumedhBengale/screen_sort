import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_sort/SelectCollectionPage.dart';
import 'package:screen_sort/globals.dart';
import 'DBFunctions.dart';
import 'HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDB();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePage(),
        'select-page': (context) => const SelectCollectionPage(),
      },
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> with WidgetsBindingObserver {
  ReceivePort? _receivePort;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000000000000000000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    if (await Permission.storage.status.isGranted) {
      if (!await FlutterForegroundTask.canDrawOverlays) {
        final isGranted =
            await FlutterForegroundTask.openSystemAlertWindowSettings();
        if (!isGranted) {
          print('SYSTEM_ALERT_WINDOW permission denied!');
          return false;
        }
      }
    } else {
      await Permission.storage.request();
      _startForegroundTask();
    }
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();
    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          if (message == 'select-page') {
            print("SS Taken");
            Navigator.of(context).pushNamed('select-page');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });
      return true;
    }
    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        SystemNavigator.pop();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Screenshots Taken:',
              ),
              Text(
                '$eventCount',
                style: Theme.of(context).textTheme.headline4,
              ),
              OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  child: const Text("Collections")),
              OutlinedButton(
                  onPressed: () {
                    for (var i = 0; i < list.length; i++) {
                      var tableName = list[i]['collection_name'];
                      print(i);
                      deleteTable(tableName);
                    }
                  },
                  child: const Text("Delete All Collections")),
              OutlinedButton(
                  onPressed: () async {
                    getCollections();
                    setState(() {});
                  },
                  child: const Text("Check Collection Status")),
              OutlinedButton(
                  onPressed: () {
                    _stopForegroundTask();
                  },
                  child: const Text("Stop Service")),
              OutlinedButton(
                  onPressed: () {
                    _startForegroundTask();
                  },
                  child: const Text("Start Service")),
              OutlinedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Exit")),
              Container(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(list[index]['collection_name'].toString()),
                    subtitle: FutureBuilder(
                        future: tableExists(list[index]['collection_name']),
                        initialData: "Loading text..",
                        builder:
                            (BuildContext context, AsyncSnapshot<String> text) {
                          return Text(text.data!);
                        }),
                  );
                },
              )),
            ],
          ),
        ));
  }
}
