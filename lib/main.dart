import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ScreenSort/Collection/SelectCollectionPage.dart';
import 'package:ScreenSort/globals.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'DBFunctions.dart';
import 'HomePage/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initDB();
  if (await FlutterForegroundTask.isRunningService) {
    serviceActive = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        'select-page': (context) => const SelectCollectionPage(),
      },
      theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      )),
    );
  }
}

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp>  {

//   @override
//   void initState() {
//     super.initState();

//   }


//   @override
//   Widget build(BuildContext context) {
//     // A widget that prevents the app from closing when the foreground service is running.
//     // This widget must be declared above the [Scaffold] widget.
//     return Scaffold(
//         backgroundColor: (serviceActive)
//             ? ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer
//             : ColorScheme.fromSeed(seedColor: Colors.pink).primaryContainer,
//         appBar: AppBar(
//           backgroundColor: (serviceActive)
//               ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
//               : ColorScheme.fromSeed(seedColor: Colors.pink).primary,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20))),
//           toolbarHeight: 100,
//           elevation: 5,
//           title: const Text('ScreenSort'),
//           centerTitle: true,
//         ),
//         body: Center(
//           child: Padding(
//             padding:
//                 EdgeInsets.only(bottom: MediaQuery.of(context).size.width / 8),
//             child: Stack(
//               children: [
//                 Center(
//                   child: RippleAnimation(
//                       repeat: true,
//                       color: (serviceActive)
//                           ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
//                           : ColorScheme.fromSeed(seedColor: Colors.pink)
//                               .primary,
//                       minRadius: 90,
//                       ripplesCount: 6,
//                       child: Container()),
//                 ),
//                 Center(
//                   child: SizedBox(
//                       width: MediaQuery.of(context).size.width / 1.5,
//                       height: MediaQuery.of(context).size.width / 1.5,
//                       child: FutureBuilder(
//                           future: checkService(),
//                           builder: (BuildContext context,
//                               AsyncSnapshot<bool> snapshot) {
//                             if (snapshot.hasData) {
//                               return ElevatedButton(
//                                 style: ButtonStyle(
//                                     backgroundColor:
//                                         MaterialStateProperty.all<Color>(
//                                       (serviceActive)
//                                           ? ColorScheme.fromSeed(
//                                                   seedColor: Colors.pink)
//                                               .primary
//                                           : ColorScheme.fromSeed(
//                                                   seedColor: Colors.pink)
//                                               .primary,
//                                     ),
//                                     shape:
//                                         MaterialStateProperty.all<CircleBorder>(
//                                             const CircleBorder(
//                                                 side: BorderSide.none))),
//                                 child: Text(
//                                   (serviceActive)
//                                       ? ("Stop Service")
//                                       : ("Start Service"),
//                                   style: const TextStyle(fontSize: 20),
//                                 ),
//                                 onPressed: () async {
//                                   if (serviceActive) {
//                                     await _stopForegroundTask();
//                                     serviceActive = false;
//                                     setState(() {});
//                                   } else {
//                                     await _startForegroundTask();
//                                     serviceActive = true;
//                                     setState(() {});
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }
//                           })),
//                 ),

//                 // IconButton(
//                 //     icon: Icon(MyApp.themeNotifier.value == ThemeMode.light
//                 //         ? Icons.dark_mode
//                 //         : Icons.light_mode),
//                 //     onPressed: () {
//                 //       MyApp.themeNotifier.value =
//                 //           MyApp.themeNotifier.value == ThemeMode.light
//                 //               ? ThemeMode.dark
//                 //               : ThemeMode.light;
//                 //     })
//               ],
//             ),
//           ),
//         ),
//         bottomSheet: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Material(
//               shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(20))),
//               color: ColorScheme.fromSeed(
//                       seedColor: (serviceActive)
//                           ? ColorScheme.fromSeed(seedColor: Colors.pink).primary
//                           : ColorScheme.fromSeed(seedColor: Colors.pink)
//                               .primary)
//                   .primary,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomePage()));
//                 },
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.height / 8,
//                   child: Center(
//                       child: Text(
//                     "Collections",
//                     style: TextStyle(
//                         color: ColorScheme.fromSeed(
//                                 seedColor: (serviceActive)
//                                     ? ColorScheme.fromSeed(
//                                             seedColor: Colors.pink)
//                                         .primary
//                                     : ColorScheme.fromSeed(
//                                             seedColor: Colors.pink)
//                                         .primary)
//                             .surface,
//                         fontSize: 20),
//                   )),
//                 ),
//               ),
//             )));
//   }
// }