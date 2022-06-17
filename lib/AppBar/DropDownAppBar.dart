//To be implemented in the Pro Version.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:screen_sort/main.dart';

import '../globals.dart';

class DropDownAppBar extends StatefulWidget {
  const DropDownAppBar({Key? key}) : super(key: key);

  @override
  State<DropDownAppBar> createState() => _DropDownAppBarState();
}

class _DropDownAppBarState extends State<DropDownAppBar> {
  Color x = ColorScheme.fromSeed(seedColor: Colors.teal).primary;
  Color y = ColorScheme.fromSeed(seedColor: Colors.green).primary;
  String selectedColor = 'x';
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 8;
    var heightExtended = MediaQuery.of(context).size.height * 3 / 4;

    Color setColor() {
      if (selectedColor == 'x') {
        return x;
      } else {
        return y;
      }
    }

    heightFunction() {
      if (extended) {
        return heightExtended;
      } else {
        return height;
      }
    }

    return (GestureDetector(
        onVerticalDragEnd: (detail) {
          print(detail);
          if (extended) {
            extended = false;
          } else {
            extended = true;
          }
          setState(() {});
        },
        child: AnimatedContainer(
          decoration: BoxDecoration(
              color: ColorScheme.fromSeed(seedColor: Colors.teal).primary,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          curve: Curves.bounceOut,
          width: MediaQuery.of(context).size.width,
          height: heightFunction(),
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              // SafeArea(
              //     child: IconButton(
              //         icon: Icon(
              //             ExampleApp.themeNotifier.value == ThemeMode.light
              //                 ? Icons.dark_mode
              //                 : Icons.light_mode),
              //         onPressed: () {
              //           ExampleApp.themeNotifier.value =
              //               ExampleApp.themeNotifier.value == ThemeMode.light
              //                   ? ThemeMode.dark
              //                   : ThemeMode.light;
              //           setState(() {});
              //         })),
              Expanded(
                  child: SafeArea(
                      child: Container(
                          height: 100,
                          color: setColor(),
                          child: Center(
                              child: OutlinedButton(
                            onPressed: () {
                              if (selectedColor == 'x') {
                                selectedColor = 'y';
                                // setState(() {});
                              } else {
                                selectedColor = 'x';
                                // setState(() {});
                              }
                            },
                            child: const Text("Change"),
                          ))))),
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "ScreenSort",
                  style: TextStyle(fontSize: 25),
                ),
              )
            ],
          ),
        )));
  }
}
