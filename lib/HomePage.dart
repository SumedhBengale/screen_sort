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
    getData();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(4),
          // ignore: sort_child_properties_last
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
                            var x = snapshot.data?[index]['collection_name'];
                            int id = snapshot.data?[index]['id'];
                            String collectionName =
                                list[index]['collection_name'];
                            print("Clicked $x");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CollectionPage(id, collectionName)));
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
