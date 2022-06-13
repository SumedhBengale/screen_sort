import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class EMPTY extends StatefulWidget {
  const EMPTY({Key? key}) : super(key: key);

  @override
  State<EMPTY> createState() => _EMPTYState();
}

class _EMPTYState extends State<EMPTY> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("EPMPTY WIDGET"),
      ),
    );
  }
}
