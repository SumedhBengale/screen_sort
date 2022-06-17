import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:screen_sort/globals.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../DBFunctions.dart';
import 'ViewImage.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage(this.id, this.collectionName, {Key? key})
      : super(key: key);
  final int id;
  final String collectionName;
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  final ImagePicker _picker = ImagePicker();
  double _scaleFactor = 150;
  double _baseScaleFactor = 1.0;

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
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late List<Map> currentCollection;
    String thisCollection = widget.collectionName;
    Future<List<Map>> collectionData() async {
      currentCollection =
          await database.rawQuery('SELECT * FROM $thisCollection');
      print(currentCollection);
      print(currentCollection.reversed.toList());
      return currentCollection.reversed.toList();
    }

    return Scaffold(
      backgroundColor: (serviceActive)
          ? ColorScheme.fromSeed(seedColor: Colors.red).primaryContainer
          : ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer,
      appBar: AppBar(
        backgroundColor: (serviceActive)
            ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
            : ColorScheme.fromSeed(seedColor: Colors.teal).primary,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        elevation: 5,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  isFilePickerActive = true;
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  insertThisImage(thisCollection, image!.path);
                  isFilePickerActive = false;
                  setState(() {});
                },
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  size: 26.0,
                ),
              )),
        ],
        title: Text(thisCollection),
      ),
      body: GestureDetector(
          onScaleStart: (details) {
            _baseScaleFactor = _scaleFactor;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scaleFactor = _baseScaleFactor * details.scale;
            });
          },
          child: FutureBuilder(
              future: collectionData(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: MasonryGridView.extent(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              maxCrossAxisExtent: _scaleFactor,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) => GestureDetector(
                                  onLongPress: () {},
                                  onTap: () {
                                    String path = snapshot.data![index]['file']
                                        .toString();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewImage(path)));
                                  },
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                          File(snapshot.data![index]['file']
                                              .toString()),
                                          fit: BoxFit.fitWidth))))));
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
