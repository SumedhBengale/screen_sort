import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage(this.id, this.collectionName, {Key? key})
      : super(key: key);
  final String id;
  final String collectionName;
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.id),
          Text(widget.collectionName),
        ],
      )),
    );
  }
}
