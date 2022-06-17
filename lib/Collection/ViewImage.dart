import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ViewImage extends StatefulWidget {
  const ViewImage(this.path, {Key? key}) : super(key: key);

  final path;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            child: PhotoView(
                minScale: 0.15,
                maxScale: 2.0,
                imageProvider: FileImage(File(widget.path))),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    color: Colors.black,
                    height: 100,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Share.shareFiles([widget.path]);
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text("Share",
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                )),
                          ),
                          GestureDetector(
                              onTap: () {
                                OpenFile.open(widget.path);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Open With",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
