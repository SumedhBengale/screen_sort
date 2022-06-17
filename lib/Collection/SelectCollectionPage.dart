import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:screen_sort/HomePage/CollectionName.dart';
import 'package:screen_sort/DBFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../globals.dart';

class SelectCollectionPage extends StatefulWidget {
  const SelectCollectionPage({Key? key}) : super(key: key);

  @override
  State<SelectCollectionPage> createState() => _SelectCollectionPageState();
}

class _SelectCollectionPageState extends State<SelectCollectionPage> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

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

  initDB() async {
    var databasesPath = await getDatabasesPath();
    dbPath = p.join(databasesPath, 'screensort.db');
    database = await openDatabase(dbPath, version: 1);
  }

  @override
  void initState() {
    initDB();
    getData();
    setState(() {});
    super.initState();
  }

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
        title: const Text("Select Collecton"),
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
                          initDB();
                          setState(() {});
                        });
                      });
                  print("Here");
                },
                child: const Icon(
                  Icons.create_new_folder_rounded,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(4),
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
                            insertImage(
                                snapshot.data?[index]['collection_name']);
                            SystemNavigator.pop();
                          },
                        );
                      });
                } else {
                  return const CircularProgressIndicator();
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
