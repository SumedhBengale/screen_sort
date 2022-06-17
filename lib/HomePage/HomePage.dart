import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_sort/HomePage/CollectionName.dart';
import '../Collection/CollectionPage.dart';
import '../DBFunctions.dart';
import '../globals.dart';
import '../AdListener.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void setState(VoidCallback fn) {
    print("Yeah");
    super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: 'ca-app-pub-4664789967062460/9484065555',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  void initState() {
    getData();
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (serviceActive)
          ? ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer
          : ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer,
      appBar: AppBar(
        backgroundColor: (serviceActive)
            ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
            : ColorScheme.fromSeed(seedColor: Colors.teal).primary,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        toolbarHeight: 100,
        elevation: 5,
        title: const Text("All Collections"),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CollectionName(onCollectionAdd: () async {
                          print("Yes");
                          await getData();
                          setState(() {});
                        });
                      });
                  print("Here");
                },
                child: const Icon(
                  Icons.create_new_folder_rounded,
                  size: 35.0,
                ),
              )),
        ],
      ),
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
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (BuildContext buildContext, index) {
                        return GestureDetector(
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder,
                                size: 90,
                                color: (serviceActive)
                                    ? ColorScheme.fromSeed(
                                            seedColor: Colors.pink)
                                        .primary
                                    : ColorScheme.fromSeed(
                                            seedColor: Colors.teal)
                                        .primary,
                              ),
                              Center(
                                  child: Text(
                                snapshot.data?[index]['collection_name'],
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
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
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          deleteCollection(
                                              list[index]['collection_name']);
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete Collection")),
                                  );
                                });
                          },
                        );
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
      bottomSheet: (_anchoredAdaptiveAd != null && _isLoaded)
          ? Container(
              color: Colors.white,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
          : Container(height: 0),
    );
  }
}
