import 'package:flutter/material.dart';
import 'package:screen_sort/CollectionName.dart';
import 'CollectionPage.dart';
import 'DBFunctions.dart';
import 'globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void setState(VoidCallback fn) {
    print("Yeah");
    super.setState(fn);
  }

  @override
  void initState() {
    getCollections();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // Text("$list"),
          // Text(list.length.toString()),
          // TextField(controller: collection_name),
          // OutlinedButton(
          //     onPressed: () => {
          //           Navigator.pop(context),
          //         },
          //     child: const Text("Back")),
          // OutlinedButton(
          //     onPressed: () {
          //       insertData();
          //     },
          //     child: const Text("Insert Collection"))
          Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: list.length,
                  itemBuilder: (BuildContext buildContext, index) {
                    return GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(list[index]['collection_name']),
                      ),
                      onTap: () {
                        var x = list[index]['collection_name'];
                        String id = list[index]['id'].toString();
                        String collectionName = list[index]['collection_name'];
                        print("Clicked $x");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CollectionPage(id, collectionName)));
                      },
                    );
                  })),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          showDialog(
              context: context,
              builder: (context) {
                return CollectionName(onCollectionAdd: () async {
                  print("Yes");
                  await getData();
                  setState(() {});
                });
              }),
          print("Here"),
          // getData();
        },
        label: const Text("New Collection"),
        // child: const Text("Add Folder"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
