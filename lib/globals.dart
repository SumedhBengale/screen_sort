import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:ScreenSort/DBFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watcher/watcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

String dbPath = '';
late Database database;
List<Map> list = [];
late Watcher watcher;
late int opentimestamp;
late DateTime latestfiletimestamp;
SendPort? _sendPort;
ReceivePort? receivePort;
String latestFilePath = '';
bool isFilePickerActive = false;
bool isAskingPermissions = false;
bool serviceActive = false;

Future<void> initDB() async {
  var databasesPath = await getDatabasesPath();
  dbPath = p.join(databasesPath, 'screensort.db');
  database = await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(
        'CREATE TABLE collections (id INTEGER PRIMARY KEY, collection_name TEXT)');
    await db.execute(
        'CREATE TABLE info (id INTEGER PRIMARY KEY, open_timestamp TEXT)');
    await db.execute(
        'CREATE TABLE temp (id INTEGER PRIMARY KEY, name TEXT, path TEXT, datetime TEXT)');
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
          notificationTitle: 'ScreenSort',
          notificationText: 'File Watching Service');

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
        var latestFileName = p.basename(event.path);
        latestFilePath = event.path;
        var latestFileDateTime =
            FileStat.statSync(event.path).modified.toString();
        print(event.path);
        print("Yes");
        await database.rawInsert(
            'INSERT INTO temp(name, path, datetime) VALUES("$latestFileName","$latestFilePath","$latestFileDateTime")');
        latestfiletimestamp = DateTime.now();
        onEvent(latestfiletimestamp, _sendPort);
      }
    });
  }
}
