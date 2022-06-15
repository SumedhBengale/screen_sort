import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_sort/CollectionName.dart';
import 'package:screen_sort/DBFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'globals.dart';

class SelectCollectionPage extends StatefulWidget {
  const SelectCollectionPage({Key? key}) : super(key: key);

  @override
  State<SelectCollectionPage> createState() => _SelectCollectionPageState();
}

class _SelectCollectionPageState extends State<SelectCollectionPage> {
  initDB() async {
    var databasesPath = await getDatabasesPath();
    dbPath = p.join(databasesPath, 'screensort.db');
    database = await openDatabase(dbPath, version: 1);
  }

  @override
  void initState() {
    initDB();
    getData();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(4),
          child: FutureBuilder(
              future: getData(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (BuildContext buildContext, index) {
                        return GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(15)),
                            child:
                                Text(snapshot.data?[index]['collection_name']),
                          ),
                          onTap: () {
                            insertImage(
                                snapshot.data?[index]['collection_name']);
                            SystemNavigator.pop();
                          },
                        );
                      });
                } else {
                  return const CircularProgressIndicator();
                }
              })),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          showDialog(
              context: context,
              builder: (context) {
                return CollectionName(onCollectionAdd: () async {
                  print("Yes");
                  initDB();
                  setState(() {});
                });
              }),
          print("Here"),
          // getData();
        },
        label: const Text("Add New Container"),
        // child: const Text("Add Folder"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
