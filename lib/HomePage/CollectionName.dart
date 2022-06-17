// ignore: file_names
import 'package:flutter/material.dart';
import 'package:screen_sort/DBFunctions.dart';
import 'package:screen_sort/globals.dart';
import 'package:sqflite/sqflite.dart';
import '../DBFunctions.dart';
import '../main.dart' as main;

class CollectionName extends StatelessWidget {
  const CollectionName({Key? key, required this.onCollectionAdd})
      : super(key: key);
  final VoidCallback onCollectionAdd;

  @override
  Widget build(BuildContext context) {
    final alphabets = RegExp(r"^[\p{L} ,.'-]*$",
        caseSensitive: false, unicode: true, dotAll: true);

    TextEditingController collectionName = TextEditingController();
    bool duplicate = false;
    return Dialog(
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: (serviceActive)
                ? ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer
                : ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer,
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
                            ? ColorScheme.fromSeed(seedColor: Colors.red)
                                .primary
                            : ColorScheme.fromSeed(seedColor: Colors.teal)
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
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'The Collection already exists.'),
                                        ))
                                      }
                                  }
                                else
                                  {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Only Alphabets are allowed.'),
                                    ))
                                  }
                              }
                            else
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Please Enter a Name for the Collection'),
                                ))
                              }
                          },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                        (serviceActive)
                            ? ColorScheme.fromSeed(seedColor: Colors.pink)
                                .primary
                            : ColorScheme.fromSeed(seedColor: Colors.teal)
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
