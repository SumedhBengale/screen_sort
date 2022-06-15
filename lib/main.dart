import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_sort/SelectCollectionPage.dart';
import 'package:screen_sort/globals.dart';
import 'DBFunctions.dart';
import 'HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
        '/': (context) => const HomePage(),
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

class _ExamplePageState extends State<ExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
