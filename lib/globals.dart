import 'dart:io';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:screen_sort/DBFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as p;

String dbPath = '';
late Database database;
List<Map> list = [];
late Watcher watcher;
late int opentimestamp;
late DateTime latestfiletimestamp;
SendPort? _sendPort;
ReceivePort? receivePort;
int eventCount = 0;
String latestFilePath = '';

Future<void> initDB() async {
  var databasesPath = await getDatabasesPath();
  dbPath = p.join(databasesPath, 'screensort.db');
  database = await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(
        'CREATE TABLE collections (id INTEGER PRIMARY KEY, collection_name TEXT)');
    await db.execute(
        'CREATE TABLE info (id INTEGER PRIMARY KEY, open_timestamp TEXT)');
    await db.execute('CREATE TABLE temp (id INTEGER PRIMARY KEY, file TEXT)');
  });
}

void getCollections() async {
  await initDB();
  await getData();
}

void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    startWatcher();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    if (timestamp == latestfiletimestamp) {
      FlutterForegroundTask.updateService(
          notificationTitle: 'MyTaskHandler',
          notificationText: 'eventCount: $eventCount');

      // Send data to the main isolate.
      sendPort?.send(eventCount);
      eventCount++;
      FlutterForegroundTask.launchApp("select-page");
      _sendPort?.send('select-page');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  Future<void> startWatcher() async {
    var databasesPath = await getDatabasesPath();
    dbPath = p.join(databasesPath, 'screensort.db');
    database = await openDatabase(dbPath, version: 1);
    List<Map> temp_list = await database.rawQuery("SELECT * FROM temp");
    String ssPath = '/storage/emulated/0/DCIM/Screenshots';
    var watcher = DirectoryWatcher(ssPath);
    watcher.events.listen((event) async {
      if (event.type.toString() == 'add') {
        latestFilePath = event.path;
        print(event.path);
        print("Yes");
        await database
            .rawInsert('INSERT INTO temp(file) VALUES("$latestFilePath")');
        latestfiletimestamp = DateTime.now();
        onEvent(latestfiletimestamp, _sendPort);
      }
    });
  }
}
