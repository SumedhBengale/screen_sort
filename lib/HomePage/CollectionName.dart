// ignore: file_names
import 'package:flutter/material.dart';
import 'package:ScreenSort/DBFunctions.dart';
import 'package:ScreenSort/globals.dart';
import 'package:sqflite/sqflite.dart';
import '../DBFunctions.dart';
import '../main.dart' as main;

class CollectionName extends StatelessWidget {
  const CollectionName({Key? key, required this.onCollectionAdd})
      : super(key: key);
  final VoidCallback onCollectionAdd;

  @override
  Widget build(BuildContext context) {
    final alphabets = RegExp(r"^[\p{L}]*$",
        caseSensitive: false, unicode: true, dotAll: true);

    TextEditingController collectionName = TextEditingController();
    bool duplicate = false;
    return Dialog(
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: (serviceActive)
                ? ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer
                : ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer,
          ),
          borderRadius: BorderRadius.circular(15)),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: ColorScheme.fromSeed(seedColor: Colors.grey)
                            .primary,
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: (serviceActive)
                            ? ColorScheme.fromSeed(seedColor: Colors.teal)
                                .primary
                            : ColorScheme.fromSeed(seedColor: Colors.pink)
                                .primary,
                      )),
                      hintText: 'Name',
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                  child: ElevatedButton(
                      onPressed: () => {
                            if (collectionName.text.isNotEmpty)
                              {
                                if (alphabets.hasMatch(collectionName.text))
                                  {
                                    for (int i = 0; i < list.length; i++)
                                      {
                                        if (list[i]['collection_name'] ==
                                            collectionName.text)
                                          duplicate = true
                                      },
                                    if (duplicate == false)
                                      {
                                        createCollection(collectionName.text),
                                        print(collectionName.text.trim()),
                                        onCollectionAdd(),
                                        Navigator.pop(context)
                                      }
                                    else
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: (serviceActive)
                                              ? ColorScheme.fromSeed(
                                                      seedColor: Colors.teal)
                                                  .primary
                                              : ColorScheme.fromSeed(
                                                      seedColor: Colors.pink)
                                                  .primary,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: (serviceActive)
                                                    ? ColorScheme.fromSeed(
                                                            seedColor:
                                                                Colors.teal)
                                                        .primary
                                                    : ColorScheme.fromSeed(
                                                            seedColor:
                                                                Colors.pink)
                                                        .primary,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20))),
                                          content: Text(
                                              'Only Alphabets are allowed.'),
                                        ))
                                      }
                                  }
                                else
                                  {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: (serviceActive)
                                          ? ColorScheme.fromSeed(
                                                  seedColor: Colors.teal)
                                              .primary
                                          : ColorScheme.fromSeed(
                                                  seedColor: Colors.pink)
                                              .primary,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: (serviceActive)
                                                ? ColorScheme.fromSeed(
                                                        seedColor: Colors.teal)
                                                    .primary
                                                : ColorScheme.fromSeed(
                                                        seedColor: Colors.pink)
                                                    .primary,
                                          ),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      content:
                                          Text('Only Alphabets are allowed.'),
                                    ))
                                  }
                              }
                            else
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: (serviceActive)
                                      ? ColorScheme.fromSeed(
                                              seedColor: Colors.teal)
                                          .primary
                                      : ColorScheme.fromSeed(
                                              seedColor: Colors.pink)
                                          .primary,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: (serviceActive)
                                            ? ColorScheme.fromSeed(
                                                    seedColor: Colors.teal)
                                                .primary
                                            : ColorScheme.fromSeed(
                                                    seedColor: Colors.pink)
                                                .primary,
                                      ),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  content: Text(
                                      'Please enter a name for the Collection.'),
                                ))
                              }
                          },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                        (serviceActive)
                            ? ColorScheme.fromSeed(seedColor: Colors.teal)
                                .primary
                            : ColorScheme.fromSeed(seedColor: Colors.pink)
                                .primary,
                      )),
                      child: const SizedBox(
                          height: 20,
                          width: double.infinity,
                          child: Text(
                            "Add New Collection",
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
