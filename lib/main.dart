import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_sort/AppBuilder.dart';
import 'package:screen_sort/Collection/SelectCollectionPage.dart';
import 'package:screen_sort/globals.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'DBFunctions.dart';
import 'AppBar/DropDownAppBar.dart';
import 'HomePage/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initDB();
  if (await FlutterForegroundTask.isRunningService) {
    serviceActive = true;
  }
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const MyApp(),
          'select-page': (context) => const SelectCollectionPage(),
        },
        theme: ThemeData(
            bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        )),
      );
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: (serviceActive)
              ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
              : ColorScheme.fromSeed(seedColor: Colors.teal).primary,
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

  Future _startForegroundTask() async {
    if (await Permission.storage.status.isGranted) {
      if (await FlutterForegroundTask.canDrawOverlays) {
        if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
          if (await FlutterForegroundTask.isRunningService) {
            serviceActive = true;
            receivePort = await FlutterForegroundTask.restartService();
          } else {
            serviceActive = true;
            receivePort = await FlutterForegroundTask.startService(
              notificationTitle: 'ScreenSort',
              notificationText: 'File Watching Service',
              callback: startCallback,
            );
          }
          return _registerReceivePort(receivePort);
        } else {
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        }
      } else {
        await FlutterForegroundTask.openSystemAlertWindowSettings();
      }
    } else {
      await Permission.storage.request();
    }
  }

  Future<bool> _stopForegroundTask() async {
    serviceActive = false;
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();
    if (receivePort != null) {
      receivePort = receivePort;
      receivePort.listen((message) {
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
    receivePort?.close();
    receivePort = null;
  }

  Future<bool> checkService() async {
    if (await FlutterForegroundTask.isRunningService) {
      serviceActive = true;
      return true;
    } else {
      serviceActive = false;
      return false;
    }
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (isFilePickerActive == false && isAskingPermissions == false) {
          SystemNavigator.pop();
        }
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _closeReceivePort();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return Scaffold(
        backgroundColor: (serviceActive)
            ? ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer
            : ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer,
        appBar: AppBar(
          backgroundColor: (serviceActive)
              ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
              : ColorScheme.fromSeed(seedColor: Colors.teal).primary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          toolbarHeight: 100,
          elevation: 5,
          title: const Text('ScreenSort'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).size.width / 8),
            child: Stack(
              children: [
                Center(
                  child: RippleAnimation(
                      repeat: true,
                      color: (serviceActive)
                          ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
                          : ColorScheme.fromSeed(seedColor: Colors.teal)
                              .primary,
                      minRadius: 90,
                      ripplesCount: 6,
                      child: Container()),
                ),
                Center(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.width / 1.5,
                      child: FutureBuilder(
                          future: checkService(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasData) {
                              return ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      (serviceActive)
                                          ? ColorScheme.fromSeed(
                                                  seedColor: Colors.pink)
                                              .primary
                                          : ColorScheme.fromSeed(
                                                  seedColor: Colors.teal)
                                              .primary,
                                    ),
                                    shape:
                                        MaterialStateProperty.all<CircleBorder>(
                                            const CircleBorder(
                                                side: BorderSide.none))),
                                child: Text(
                                  (serviceActive)
                                      ? ("Stop Service")
                                      : ("Start Service"),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (serviceActive) {
                                    await _stopForegroundTask();
                                    serviceActive = false;
                                    setState(() {});
                                  } else {
                                    await _startForegroundTask();
                                    serviceActive = true;
                                    setState(() {});
                                  }
                                },
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          })),
                ),

                // IconButton(
                //     icon: Icon(ExampleApp.themeNotifier.value == ThemeMode.light
                //         ? Icons.dark_mode
                //         : Icons.light_mode),
                //     onPressed: () {
                //       ExampleApp.themeNotifier.value =
                //           ExampleApp.themeNotifier.value == ThemeMode.light
                //               ? ThemeMode.dark
                //               : ThemeMode.light;
                //     })
              ],
            ),
          ),
        ),
        bottomSheet: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Material(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              color: ColorScheme.fromSeed(
                      seedColor: (serviceActive)
                          ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
                          : ColorScheme.fromSeed(seedColor: Colors.teal)
                              .primary)
                  .primary,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 8,
                  child: Center(
                      child: Text(
                    "Collections",
                    style: TextStyle(
                        color: ColorScheme.fromSeed(
                                seedColor: (serviceActive)
                                    ? ColorScheme.fromSeed(
                                            seedColor: Colors.teal)
                                        .primary
                                    : ColorScheme.fromSeed(
                                            seedColor: Colors.teal)
                                        .primary)
                            .surface,
                        fontSize: 20),
                  )),
                ),
              ),
            )));
  }
}
