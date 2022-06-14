import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:screen_sort/CollectionName.dart';
import 'package:screen_sort/globals.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage(this.id, this.collectionName, {Key? key})
      : super(key: key);
  final int id;
  final String collectionName;
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  @override
  Widget build(BuildContext context) {
    late List<Map> currentCollection;
    String thisCollection = widget.collectionName;
    Future<List<Map>> collectionData() async {
      currentCollection =
          await database.rawQuery('SELECT * FROM $thisCollection');
      return currentCollection;
    }

    return Scaffold(
      body: FutureBuilder(
          future: collectionData(),
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.id.toString()),
                  Text(widget.collectionName),
                  Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title:
                                    Text(currentCollection[index].toString()));
                          }))
                ],
              ));
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
