import 'dart:async';

import 'package:fitness_app/screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

late ObjectBox objectbox;
bool objectboxIsInitialized = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => CnBottomMenu()),
        ChangeNotifierProvider(create: (context) => CnWorkouts()),
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnRunningWorkout()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnHomepage()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
        ChangeNotifierProvider(create: (context) => CnSpotifyBar()),
        ChangeNotifierProvider(create: (context) => PlayerStateStream()),
        ChangeNotifierProvider(create: (context) => CnNewWorkOutPanel(context)),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
            useMaterial3: true,
            splashFactory: InkSparkle.splashFactory
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override

  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnHomepage cnHomepage;

  @override
  void initState() {
    initObjectBox();
    // cnSpotifyBar.connectToSpotify();
    super.initState();
  }

  void initObjectBox() async{
    objectbox = await ObjectBox.create();
    objectboxIsInitialized = true;
    print("Obejctbox Initialized");
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    print("Refreshed All Workouts");
  }

  @override
  Widget build(BuildContext context) {
    cnHomepage = Provider.of<CnHomepage>(context);
    cnHomepage.initSpotifyBar(cnSpotifyBar);
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xff84490b),
                    Colors.black.withOpacity(0.9),
                  ]
              )
          ),
          child: Column(
            children: [
              // if (cnRunningWorkout.isRunning)
              //   Container(
              //     width: double.maxFinite,
              //     height: 110,
              //     decoration: const BoxDecoration(
              //       gradient: LinearGradient(
              //           begin: Alignment.centerRight,
              //           end: Alignment.centerLeft,
              //           colors: [
              //             Color(0xff55300a),
              //             Color(0xff44260b),
              //           ]
              //       ),
              //       // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
              //     ),
              //     child: Column(
              //       children: [
              //         const SafeArea(
              //           bottom: false,
              //           child: SizedBox(),
              //         ),
              //         GestureDetector(
              //           onTap: () => cnRunningWorkout.reopenRunningWorkout(context),
              //           child: Container(
              //             height: 50,
              //             width: double.maxFinite,
              //             // color: Color(0xff44260b),
              //             decoration: const BoxDecoration(
              //                 gradient: LinearGradient(
              //                     begin: Alignment.centerRight,
              //                     end: Alignment.centerLeft,
              //                     colors: [
              //                       Color(0xff55300a),
              //                       Color(0xff44260b),
              //                     ]
              //                 ),
              //               // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
              //             ),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Text(
              //                     cnRunningWorkout.workout.name,
              //                   textScaleFactor: 1.6,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   )
              // else
              //   SizedBox(height: 0,),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    AnimatedCrossFade(
                        firstChild: ScreenWorkoutHistory(key: UniqueKey()),
                        secondChild: ScreenWorkout(key: UniqueKey()),
                        crossFadeState: cnBottomMenu.index == 0?
                        CrossFadeState.showFirst:
                        CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200)
                    ),
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 300), // Animationsdauer
                        transform: Matrix4.translationValues(0, cnNewWorkout.minPanelHeight>0? -(cnNewWorkout.minPanelHeight-cnBottomMenu.maxHeightBottomMenu) : 0, 0),
                        curve: Curves.easeInOut,
                        // child: const SpotifyBar()
                        child: const Hero(
                            transitionOnUserGestures: true,
                            tag: "SpotifyBar",
                            child: SpotifyBar()
                        ),
                    ),
                    // cnSpotifyBar.bar,
                    const NewWorkOutPanel(),
                    const NewExercisePanel(),
                    const StandardPopUp()
                  ],
                ),
              ),
            ],
          ),

        // child: AnimatedCrossFade(
        //     firstChild: ScreenWorkoutHistory(key: UniqueKey()),
        //     // firstChild: Container(height: 50, width: 50,),
        //     secondChild: ScreenWorkout(key: UniqueKey()),
        //     crossFadeState: cnBottomMenu.index == 0?
        //     CrossFadeState.showFirst:
        //     CrossFadeState.showSecond,
        //     duration: const Duration(milliseconds: 200)
        // ),
      ),
      bottomNavigationBar: const BottomMenu(),
    );
  }
}

class CnHomepage extends ChangeNotifier {
  late CnSpotifyBar cnSpotifyBar;
  bool isInitialized = false;

  void initSpotifyBar(CnSpotifyBar cn){
    if(!isInitialized){
      cnSpotifyBar = cn;
      isInitialized = true;
    }
  }

  void refresh({bool refreshSpotifyBar = false}){
    notifyListeners();
    if(refreshSpotifyBar){
      Future.delayed(const Duration(milliseconds: 500), (){
        cnSpotifyBar.refresh();
        print("REFRESH SPOTIFY BAR IN HOMEPAGE");
      });
    }
  }
}

// Klasse zur Verwaltung des Player-Zustands
class PlayerStateStream extends ChangeNotifier {
  Stream<PlayerState> get stream => SpotifySdk.subscribePlayerState();
}