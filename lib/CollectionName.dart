// ignore: file_names
import 'package:flutter/material.dart';
import 'package:screen_sort/DBFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'DBFunctions.dart';
import 'main.dart' as main;

class CollectionName extends StatelessWidget {
  const CollectionName({Key? key, required this.onCollectionAdd})
      : super(key: key);
  final VoidCallback onCollectionAdd;

  @override
  Widget build(BuildContext context) {
    TextEditingController collectionName = TextEditingController();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 16,
      child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    controller: collectionName,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Name',
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: ElevatedButton(
                      onPressed: () => {
                            createCollection(collectionName.text),
                            print(collectionName.text),
                            onCollectionAdd(),
                            Navigator.pop(context)
                          },
                      child: const SizedBox(
                          height: 20,
                          width: double.infinity,
                          child: Text(
                            "Add Folder",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ))))
            ],
          )),
    );
  }
}
