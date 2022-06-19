import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../Collection/CollectionPage.dart';
import '../DBFunctions.dart';
import '../globals.dart';
import 'CollectionName.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  Color x = ColorScheme.fromSeed(seedColor: Colors.teal).primary;
  Color y = ColorScheme.fromSeed(seedColor: Colors.pink).primary;
  String selectedColor = 'x';
  bool extended = false;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: (serviceActive)
              ? ColorScheme.fromSeed(seedColor: Colors.teal).primary
              : ColorScheme.fromSeed(seedColor: Colors.pink).primary,
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000000000000000000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future _startForegroundTask() async {
    if (await Permission.storage.status.isGranted) {
      if (await FlutterForegroundTask.canDrawOverlays) {
        if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
          if (await FlutterForegroundTask.isRunningService) {
            serviceActive = true;
            receivePort = await FlutterForegroundTask.restartService();
          } else {
            serviceActive = true;
            receivePort = await FlutterForegroundTask.startService(
              notificationTitle: 'ScreenSort',
              notificationText: 'File Watching Service',
              callback: startCallback,
            );
          }
          return _registerReceivePort(receivePort);
        } else {
          isAskingPermissions = true;
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
          isAskingPermissions = false;
          await _startForegroundTask();
          setState(() {
            serviceActive = true;
          });
        }
      } else {
        isAskingPermissions = true;
        await FlutterForegroundTask.openSystemAlertWindowSettings();
        isAskingPermissions = false;
        await _startForegroundTask();
      }
    } else {
      isAskingPermissions = true;
      await Permission.storage.request();
      isAskingPermissions = false;
      await _startForegroundTask();
    }
  }

  Future<bool> _stopForegroundTask() async {
    serviceActive = false;
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();
    if (receivePort != null) {
      receivePort = receivePort;
      receivePort.listen((message) {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          if (message == 'select-page') {
            print("SS Taken");
            Navigator.of(context).pushNamed('select-page');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });
      return true;
    }
    return false;
  }

  void _closeReceivePort() {
    receivePort?.close();
    receivePort = null;
  }

  Future<bool> checkService() async {
    if (await FlutterForegroundTask.isRunningService) {
      serviceActive = true;
      return true;
    } else {
      serviceActive = false;
      return false;
    }
  }

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

  T? _ambiguate<T>(T? value) => value;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (isFilePickerActive == false && isAskingPermissions == false) {
          SystemNavigator.pop();
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    getData();
    setState(() {});
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    _closeReceivePort();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = 150;
    var heightExtended = 300;

    heightFunction() {
      if (extended) {
        return heightExtended;
      } else {
        return height;
      }
    }

    return Scaffold(
      backgroundColor: (serviceActive)
          ? ColorScheme.fromSeed(seedColor: Colors.teal).primaryContainer
          : ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer,
      body: Column(
        children: [
          GestureDetector(
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
                    color: (serviceActive)
                        ? ColorScheme.fromSeed(seedColor: Colors.teal).primary
                        : ColorScheme.fromSeed(seedColor: Colors.pink).primary,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                curve: Curves.bounceOut,
                width: MediaQuery.of(context).size.width,
                height: heightFunction().toDouble(),
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (extended)
                        ? Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: RippleAnimation(
                                      repeat: true,
                                      color: (serviceActive)
                                          ? ColorScheme.fromSeed(
                                                  seedColor: Colors.teal)
                                              .primaryContainer
                                          : ColorScheme.fromSeed(
                                                  seedColor: Colors.pink)
                                              .primaryContainer,
                                      minRadius: 90,
                                      ripplesCount: 6,
                                      child: Container()),
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: FutureBuilder(
                                        future: checkService(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<bool> snapshot) {
                                          if (snapshot.hasData) {
                                            return ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(
                                                    (serviceActive)
                                                        ? ColorScheme.fromSeed(
                                                                seedColor:
                                                                    Colors.teal)
                                                            .primary
                                                        : ColorScheme.fromSeed(
                                                                seedColor:
                                                                    Colors.pink)
                                                            .primary,
                                                  ),
                                                  shape: MaterialStateProperty
                                                      .all<CircleBorder>(
                                                          const CircleBorder())),
                                              child: Text(
                                                (serviceActive)
                                                    ? ("Stop Service")
                                                    : ("Start Service"),
                                                style: const TextStyle(
                                                    fontSize: 20),
                                                textAlign: TextAlign.center,
                                              ),
                                              onPressed: () async {
                                                if (serviceActive) {
                                                  await _stopForegroundTask();
                                                  serviceActive = false;
                                                  setState(() {});
                                                } else {
                                                  await _startForegroundTask();
                                                  if (await Permission.storage
                                                          .status.isGranted &&
                                                      await FlutterForegroundTask
                                                          .canDrawOverlays &&
                                                      await FlutterForegroundTask
                                                          .isIgnoringBatteryOptimizations) {
                                                    serviceActive = true;
                                                    setState(() {});
                                                  }
                                                }
                                              },
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        })),
                              ),
                            ],
                          )
                        : SafeArea(
                            child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    "ScreenSort",
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: (serviceActive)
                                          ? ColorScheme.fromSeed(
                                                  seedColor: Colors.teal)
                                              .surface
                                          : ColorScheme.fromSeed(
                                                  seedColor: Colors.pink)
                                              .surface,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CollectionName(
                                                onCollectionAdd: () async {
                                              print("Yes");
                                              await getData();
                                              setState(() {});
                                            });
                                          });
                                      print("Here");
                                    },
                                    child: Icon(
                                      Icons.create_new_folder_rounded,
                                      size: 35.0,
                                      color: (serviceActive)
                                          ? ColorScheme.fromSeed(
                                                  seedColor: Colors.teal)
                                              .surface
                                          : ColorScheme.fromSeed(
                                                  seedColor: Colors.pink)
                                              .surface,
                                    ),
                                  )),
                            ],
                          ))
                  ],
                ),
              )),
          Center(
              child: (extended)
                  ? Icon(Icons.keyboard_arrow_up_rounded)
                  : Icon(Icons.keyboard_arrow_down_rounded)),
          FutureBuilder(
              future: getData(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data!.length > 0)
                      ? GridView.builder(
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
                                                seedColor: Colors.teal)
                                            .primary
                                        : ColorScheme.fromSeed(
                                                seedColor: Colors.pink)
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
                                var x =
                                    snapshot.data?[index]['collection_name'];
                                int id = snapshot.data?[index]['id'];
                                String collectionName =
                                    list[index]['collection_name'];
                                print("Clicked $x");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CollectionPage(
                                            id, collectionName)));
                              },
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        backgroundColor: (serviceActive)
                                            ? ColorScheme.fromSeed(
                                                    seedColor: Colors.teal)
                                                .primaryContainer
                                            : ColorScheme.fromSeed(
                                                    seedColor: Colors.pink)
                                                .primaryContainer,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Text(
                                                list[index]['collection_name'],
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                            ),
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(
                                                    (serviceActive)
                                                        ? ColorScheme.fromSeed(
                                                                seedColor:
                                                                    Colors.teal)
                                                            .primary
                                                        : ColorScheme.fromSeed(
                                                                seedColor:
                                                                    Colors.pink)
                                                            .primary,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  deleteCollection(list[index]
                                                      ['collection_name']);
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                    "Delete Collection")),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            );
                          })
                      : Expanded(
                          child: (serviceActive)
                              ? Image.asset(
                                  'assets/no_collection_found_teal.png')
                              : Image.asset(
                                  'assets/no_collection_found_pink.png'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
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
