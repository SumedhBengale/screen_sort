// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:intl/intl.dart';
// import 'package:screen_sort/HomePage.dart';
// import 'package:screen_sort/SelectCollectionPage.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:watcher/watcher.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path/path.dart' as p;
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'DBFunctions.dart';
// import 'globals.dart';

// void main() async {
//   runApp(const MyApp());

//   // const androidConfig = FlutterBackgroundAndroidConfig(
//   //   notificationTitle: "flutter_background example app",
//   //   notificationText:
//   //       "Background notification for keeping the example app running in the background",
//   //   notificationImportance: AndroidNotificationImportance.Default,
//   //   notificationIcon:
//   //       AndroidResource(name: 'background_icon', defType: 'drawable'),
//   // );
//   // await FlutterBackground.initialize(androidConfig: androidConfig);
//   // await FlutterBackground.hasPermissions;
//   // await FlutterBackground.enableBackgroundExecution();

//   await FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'notification_channel_id',
//       channelName: 'Foreground Notification',
//       channelDescription: 'ScreenSort Service',
//       channelImportance: NotificationChannelImportance.LOW,
//       priority: NotificationPriority.LOW,
//       iconData: const NotificationIconData(
//         resType: ResourceType.mipmap,
//         resPrefix: ResourcePrefix.ic,
//         name: 'launcher',
//       ),
//       buttons: [
//         const NotificationButton(id: 'sendButton', text: 'SS'),
//       ],
//     ),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       interval: 5000,
//       autoRunOnBoot: true,
//       allowWifiLock: true,
//     ),
//     printDevLog: true,
//   );

//   var databasesPath = await getDatabasesPath();
//   dbPath = p.join(databasesPath, 'screensort.db');
//   database = await openDatabase(dbPath, version: 1,
//       onCreate: (Database db, int version) async {
//     // When creating the db, create the table
//     await db.execute(
//         'CREATE TABLE collections (id INTEGER PRIMARY KEY, collection_name TEXT)');
//     await db.execute(
//         'CREATE TABLE info (id INTEGER PRIMARY KEY, open_timestamp TEXT)');
//   });
//   openTimeStamp = DateTime.now().microsecondsSinceEpoch;
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.amber,
//       ),
//       home: const MyHomePage(title: 'ScreenSort'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   void _incrementCounter() {
//     _counter++;
//     print("yes");
//     setState(() {});
//   }

//   void permissions() async {
//     if (await Permission.storage.status.isDenied) {
//       Permission.storage.request();
//     }
//   }

//   @override
//   initState() {
//     permissions();
//     String ssPath = '/storage/emulated/0/DCIM/Screenshots';
//     var watcher = DirectoryWatcher(ssPath);
//     watcher.events.listen((event) {
//       print(event.path);
//       var f = File(event.path);
//       var fileTimestamp =
//           FileStat.statSync(event.path).modified.microsecondsSinceEpoch;
//       print(openTimeStamp);
//       if (openTimeStamp <= fileTimestamp) {
//         _incrementCounter();
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const SelectCollectionPage()));
//       }
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WithForegroundTask(
//         child: Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Screenshots Taken:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             OutlinedButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomePage()));
//                 },
//                 child: const Text("Collections")),
//             OutlinedButton(
//                 onPressed: () {
//                   for (var i = 0; i < list.length; i++) {
//                     var tableName = list[i]['collection_name'];
//                     print(i);
//                     deleteTable(tableName);
//                   }
//                 },
//                 child: const Text("Delete All Collections")),
//             OutlinedButton(
//                 onPressed: () {
//                   getCollections();
//                   setState(() {});
//                 },
//                 child: const Text("Check Collection Status")),
//             Container(
//                 child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: list.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(list[index]['collection_name'].toString()),
//                   subtitle: FutureBuilder(
//                       future: tableExists(list[index]['collection_name']),
//                       initialData: "Loading text..",
//                       builder:
//                           (BuildContext context, AsyncSnapshot<String> text) {
//                         return Text(text.data!);
//                       }),
//                 );
//               },
//             )),
//           ],
//         ),
//       ),
//     ));
//   }
// }

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:screen_sort/EMPTY.dart';

void main() => runApp(const ExampleApp());

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
        notificationTitle: 'MyTaskHandler',
        notificationText: 'eventCount: $_eventCount');

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
    // if (id == 'empty_page') {
    FlutterForegroundTask.launchApp('/empty_page');
    _sendPort?.send('empty_page');
    onEvent(DateTime.now(), _sendPort);
    // }
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePage(),
        '/resume-route': (context) => const ResumeRoutePage(),
        '/empty-page': (context) => const EMPTY(),
      },
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
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
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
          const NotificationButton(id: 'empty_page', text: 'Empty')
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10000000000000000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
      print("Restart");
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
      print("Start");
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
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
          if (message == 'empty_page') {
            Navigator.of(context).pushNamed('/empty_page');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buttonBuilder('start', onPressed: _startForegroundTask),
          buttonBuilder('stop', onPressed: _stopForegroundTask),
        ],
      ),
    );
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
