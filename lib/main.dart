import 'dart:async';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/animated_column.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/screens/other_screens/welcome_screen.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/language_config.dart';
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/widgets/background_image.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/initial_animated_screen.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_add_workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carp_serializable/carp_serializable.dart';

late ObjectBox objectbox;
bool tutorialIsRunning = false;
int currentTutorialStep = 0;
String pictureAssetPath = "lib/assets/pictures/";

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) => context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends State<MyApp> {
  final Language _language = languages[LANGUAGES.en.value];
  late Locale _locale = Locale.fromSubtags(countryCode: _language.countryCode, languageCode: _language.languageCode);
  final GlobalKey k = GlobalKey();

  void setLocale({LANGUAGES? language, String? languageCode, CnConfig? config}) {
    final Language lan = languages[languageCode]?? languages[language?.value]?? languages[LANGUAGES.en.value];
    setState(() {
      _locale = Locale.fromSubtags(countryCode: lan.countryCode, languageCode: lan.languageCode);
      config?.setLanguage(lan.languageCode);
    });
  }

  @override
  void initState() {
    super.initState();
    // setIntlLanguage(countryCode: _language.countryCode);
    setIntlLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
        ChangeNotifierProvider(create: (context) => CnBackgroundColor()),
        ChangeNotifierProvider(create: (context) => CnAnimatedColumn()),
        ChangeNotifierProvider(create: (context) => CnWorkouts()),
        ChangeNotifierProvider(create: (context) => CnBottomMenu()),
        ChangeNotifierProvider(create: (context) => CnConfig()),
        ChangeNotifierProvider(create: (context) => CnScreenStatistics(context)),
        ChangeNotifierProvider(create: (context) => CnStopwatchWidget(context)),
        ChangeNotifierProvider(create: (context) => CnSpotifyBar(context)),
        ChangeNotifierProvider(create: (context) => CnRunningWorkout(context)),
        ChangeNotifierProvider(create: (context) => CnHomepage(context)),
        ChangeNotifierProvider(create: (context) => CnNewWorkOutPanel(context)),
      ],
      child: MaterialApp(
        // showPerformanceOverlay: true,
        locale: _locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
            // useMaterial3: true,
            splashFactory: InkSparkle.splashFactory,
            cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.dark
            )
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override

  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context); /// should be true?
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnHomepage cnHomepage;
  // late final AnimationController _animationControllerWorkoutsScreen = AnimationController(
  //   vsync: this,
  //   duration: const Duration(milliseconds: 300),
  // );
  // late final AnimationController _animationControllerStatisticsScreen = AnimationController(
  //   vsync: this,
  //   duration: const Duration(milliseconds: 300),
  // );
  bool showWelcomeScreen = false;
  bool closeWelcomeScreen = true;
  bool mainIsInitialized = false;

  @override
  void initState() {
    initMain();
    super.initState();
  }

  @override
  void dispose() {
    // _animationControllerWorkoutsScreen.dispose();
    // _animationControllerStatisticsScreen.dispose();
    super.dispose();
  }

  void setIntroScreen(){
    currentTutorialStep = cnConfig.currentTutorialStep;
    if(cnConfig.welcomeScreen){
      showWelcomeScreen = true;
      closeWelcomeScreen = false;
      cnBottomMenu.adjustHeight(1);
    }
    else{
      showWelcomeScreen = false;
      closeWelcomeScreen = true;
    }
    if(currentTutorialStep < 10 && currentTutorialStep != 0){
      tutorialIsRunning = true;
    }
  }

  void initMain() async{
    objectbox = await ObjectBox.create();
    await Future.delayed(const Duration(milliseconds: 500));
    await cnConfig.initData();
    await dotenv.load(fileName: "dotenv.env");
    if(cnConfig.config.settings["languageCode"] == null){
      if(context.mounted){
        final res = await findSystemLocale();
        MyApp.of(context)?.setLocale(languageCode: res);
      }
    }
    else if(context.mounted && cnConfig.config.settings["languageCode"] != null){
        MyApp.of(context)?.setLocale(languageCode: cnConfig.config.settings["languageCode"]);
    }
    cnRunningWorkout.initCachedData(cnConfig.config.cnRunningWorkout);
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnScreenStatistics.init(cnConfig.config.cnScreenStatistics);
    // cnWorkouts.animationControllerWorkoutsScreen = _animationControllerWorkoutsScreen;
    // cnHomepage.animationControllers["ScreenWorkouts"] = _animationControllerWorkoutsScreen;
    // cnScreenStatistics.animationControllerStatisticsScreen = _animationControllerStatisticsScreen;
    // cnHomepage.animationControllers["ScreenStatistics"] = _animationControllerStatisticsScreen;
    cnBottomMenu.setBottomMenuHeight(context);
    cnBottomMenu.refresh();

    /// setIntroScreen needs to be after cnBottomMenu.setBottomMenuHeight
    setIntroScreen();
    cnStopwatchWidget.countdownTime = cnConfig.countdownTime;

    /// open screenRunningWorkout when it's saved in config.json and the welcome screen is not shown
    if(cnRunningWorkout.isRunning && cnRunningWorkout.isVisible && !showWelcomeScreen){
      Future.delayed(const Duration(milliseconds: 300), (){
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const ScreenRunningWorkout()
            ));
      });
    }


    /// sign in and sync with cloud
    await cnConfig.signInCloud();
    if(!showWelcomeScreen && cnConfig.syncMultipleDevices){
      trySyncWithCloud();
    }

    // await Future.delayed(const Duration(milliseconds: 200), () async {
    //   if(cnConfig.connectWithCloud){
    //     if(Platform.isAndroid){
    //       await cnConfig.signInGoogleDrive(delayMilliseconds: 0);
    //     }
    //     if(Platform.isIOS){
    //       await cnConfig.checkIfICloudAvailable(delayMilliseconds: 0);
    //     }
    //     print("SHOULD SYNC? ${cnConfig.syncMultipleDevices}");
    //     if(!showWelcomeScreen && cnConfig.syncMultipleDevices){
    //       trySyncWithCloud();
    //     }
    //   }
    // });
    setState(() {
      mainIsInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    cnHomepage = Provider.of<CnHomepage>(context);

    /// Screen to bee shown until 'await cnConfig.initData();' is finished
    /// So the config data is been initialized
    /// And also main needs to be initialised
    /// !cnConfig.isInitialized seems unimportant since, mainIsInitialized can only be true when
    /// cnConfig.isInitialized is also true, however deleting it leads some to a crash
    if(!cnConfig.isInitialized || !mainIsInitialized){
      return Scaffold(
        body: Container(
          // color: Theme.of(context).primaryColor,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffc26a0e),
                    Color(0xbb110a02)
                  ]
              )
          ),
          child: Center(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
                    child: Image.asset(
                        // scale: 0.01,
                        "${pictureAssetPath}Logo removed HD only dumbell.png"
                    ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 125),
                    child: Text(
                        "OneDay",
                        textScaler: TextScaler.linear(4),
                        style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.white)
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: CupertinoActivityIndicator(
                              radius: 20.0,
                              color: Colors.amber[800]
                          ),
                        ),
                        // child: Center(child: CircularProgressIndicator())
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if(cnConfig.currentTutorialStep == 0 && showWelcomeScreen == false && closeWelcomeScreen == true && !tutorialIsRunning){
      tutorialIsRunning = true;
      initTutorialAddWorkout(context);
      showTutorialAddWorkout(context);
    }
    // print("is running $tutorialIsRunning");

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const BottomMenu(),
      body: PopScope(
        canPop: false,
        child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffc26a0e),
                      Color(0xbb110a02)
                    ]
                )
            ),
          // decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //         begin: Alignment.topRight,
          //         end: Alignment.bottomLeft,
          //         colors: [
          //           Color(0x95c26a0e),
          //           Color(0x7f110a02)
          //         ]
          //     )
          // ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if(cnBottomMenu.index != 2)
                  Stack(
                    children: [
                      /// Animated Builder to Reduce Size of left and middle screen when workout panel is opened
                      // AnimatedBuilder(
                      //   animation: _animationControllerWorkoutsScreen,
                      //   builder: (context, child) {
                      //     double scale = 1.0 - (_animationControllerWorkoutsScreen.value * (Platform.isAndroid? 0.15 : 0.2));
                      //     double borderRadius = 26 - (scale*10-9)*20;
                      //     borderRadius = borderRadius > 25 ? 25 : borderRadius;
                      //     return Transform.scale(
                      //       scale: scale,
                      //       child: ClipRRect(
                      //         borderRadius: BorderRadius.circular(borderRadius),
                      //           child: Container(
                      //             decoration: const BoxDecoration(
                      //                   gradient: LinearGradient(
                      //                       begin: Alignment.topRight,
                      //                       end: Alignment.bottomLeft,
                      //                       colors: [
                      //                         Color(0xffc26a0e),
                      //                         Color(0xbb110a02)
                      //                       ]
                      //                   )
                      //               ),
                      //             child: Container(
                      //                 color: Colors.black.withOpacity((_animationControllerWorkoutsScreen.value * 1.1).clamp(0, 1)),
                      //                 child: child
                      //             ),
                      //           )
                      //       ),
                      //     );
                      //   },
                      //   child: AnimatedCrossFade(
                      //       firstChild: const ScreenWorkoutHistory(),
                      //       secondChild: const ScreenWorkout(),
                      //       crossFadeState: cnBottomMenu.index == 0?
                      //       CrossFadeState.showFirst:
                      //       CrossFadeState.showSecond,
                      //       duration: const Duration(milliseconds: 100)
                      //   ),
                      // ),
                      InitialAnimatedScreen(
                          animationControllerName: "ScreenWorkouts",
                          child: AnimatedCrossFade(
                              firstChild: const ScreenWorkoutHistory(),
                              secondChild: const ScreenWorkout(),
                              crossFadeState: cnBottomMenu.index == 0?
                              CrossFadeState.showFirst:
                              CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 100)
                          ),
                      ),

                      if(cnConfig.useSpotify)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: Matrix4.translationValues(0, cnNewWorkout.minPanelHeight>0? -(cnNewWorkout.minPanelHeight-cnBottomMenu.height) : 0, 0),
                          curve: Curves.easeInOut,
                          child: const SafeArea(
                            top: false,
                            child: Hero(
                                transitionOnUserGestures: true,
                                tag: "SpotifyBar",
                                child: SpotifyBar()
                            ),
                          ),
                        ),
                      const NewWorkOutPanel(),
                      const NewExercisePanel(),
                    ],
                  )
                else
                  const ScreenStatistics(),
                // const Align(
                //     alignment: Alignment.bottomCenter,
                //     child: BottomMenu()
                // ),
                const StandardPopUp(),
                if(showWelcomeScreen)
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    firstChild: WelcomeScreen(
                      onFinish: onFinishWelcomeScreen
                    ),
                    /// Use transparent Container instead of SizedBox to prevent user inputs
                    /// until tutorial is loaded
                    secondChild: Container(
                      color: Colors.transparent,
                    ),
                    crossFadeState: closeWelcomeScreen?
                    CrossFadeState.showSecond :
                    CrossFadeState.showFirst,
                    layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            key: bottomChildKey,
                            // top: 0.0,
                            child: bottomChild,
                          ),
                          Positioned(
                            key: topChildKey,
                            child: topChild,
                          ),
                        ],
                      );
                    },
                  ),
                if(cnHomepage.isSyncingWithCloud)
                  IgnorePointer(
                    child: SafeArea(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            height: cnRunningWorkout.isRunning && cnBottomMenu.index == 1? 55 : (Platform.isAndroid? 10 : 0),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withOpacity(0.4)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 5),
                                Text(cnHomepage.msg, style: const TextStyle(color: CupertinoColors.white)),
                                const SizedBox(width: 5),
                                if(cnHomepage.percent != null)
                                  Text("${(cnHomepage.percent! * 100).round()}%", style: const TextStyle(color: CupertinoColors.white)),
                                if(cnHomepage.percent != null)
                                const SizedBox(width: 5),
                                if(!cnHomepage.syncWithCloudCompleted)
                                  SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CupertinoActivityIndicator(
                                            radius: 8.0,
                                            color: Colors.amber[800]
                                        ),
                                      ),
                                      // child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1,))
                                  )
                                else
                                  const Icon(
                                    Icons.check_circle,
                                    size: 15,
                                    color: Colors.green
                                  ),
                                const SizedBox(width: 5)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Center(
                //   child: ElevatedButton(
                //     child: Text("Test"),
                //     onPressed: ()async{
                //       print("Presses Center button");
                //       tryHealthData();
                //       // print("RESULT res: $res");
                //     },
                //   ),
                // )
              ],
            ),
        ),
      ),
    );
  }

  Future<void> trySyncWithCloud() async{
    cnHomepage.isSyncingWithCloud = true;
    cnHomepage.msg = "Sync with Google Drive";
    if(Platform.isAndroid){
      if(await hasInternet()){
        cnHomepage.refresh();
        await loadNewestDataGoogleDrive(
            cnConfig,
            cnHomepage: cnHomepage
        ).then((needRefresh) {
          if(needRefresh){
            cnWorkouts.refreshAllWorkouts();
            cnWorkoutHistory.refreshAllWorkouts();
          }
        });
      }
      else{
        cnHomepage.isSyncingWithCloud = false;
        cnHomepage.msg = "";
        Fluttertoast.showToast(
            msg: "No Internet - Sync with Cloud not possible",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.grey[800]?.withOpacity(0.9),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
    else{
      cnHomepage.isSyncingWithCloud = true;
      cnHomepage.msg = "Sync with iCloud";
      cnHomepage.refresh();
      await loadNewestDataiCloud(cnHomepage: cnHomepage).then((needRefresh) {
        if(needRefresh){
          cnWorkouts.refreshAllWorkouts();
          cnWorkoutHistory.refreshAllWorkouts();
        }
      });
      // loadNewestDataGoogleDrive(
      //     cnConfig,
      //     cnHomepage: cnHomepage
      // ).then((needRefresh) {
      //   if(needRefresh){
      //     cnWorkouts.refreshAllWorkouts();
      //     cnWorkoutHistory.refreshAllWorkouts();
      //   }
      // });
    }
  }

  void onFinishWelcomeScreen(bool doShowTutorial) {
    cnConfig.setWelcomeScreen(false);
    setState(() {
      closeWelcomeScreen = true;
    });
    Future.delayed(const Duration(milliseconds: 500), ()async{
      setState(() {
        cnBottomMenu.showBottomMenuAnimated();
        if(doShowTutorial && currentTutorialStep == 0) {
          initTutorialAddWorkout(context);
          showTutorialAddWorkout(context);
        } else if(!doShowTutorial){
          currentTutorialStep = maxTutorialStep;
          cnConfig.setCurrentTutorialStep(currentTutorialStep);
          tutorialIsRunning = false;
        }
        showWelcomeScreen = false;
      });
      if(cnConfig.syncMultipleDevices /*&& !doShowTutorial*/){
        trySyncWithCloud();
      }
    });
  }
}

void tryHealthData()async{
  // Global Health instance
  final health = Health();

  // configure the health plugin before use.
  await health.configure();
  var types = [
    HealthDataType.WEIGHT
  ];
  bool requested = await health.requestAuthorization(types);
  var now = DateTime.now();
  DateTime startTime = DateTime(2000, 1, 1);
  List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      startTime: startTime, endTime: now, types: types);

  for(HealthDataPoint h in healthData){
    print(h.dateFrom);
    print(h.value);
    print("");
  }
  print(healthData.length);
  // print(healthData);
}

class CnHomepage extends ChangeNotifier {
  late CnSpotifyBar cnSpotifyBar;
  bool isSyncingWithCloud = false;
  bool syncWithCloudCompleted = false;
  double? percent;
  String msg = "";
  Map<String, AnimationController> animationControllers = {};

  updateSyncStatus(double percent){
    this.percent = percent;
    if(percent > 0 && percent < 1){
      isSyncingWithCloud = true;
      syncWithCloudCompleted = false;
      refresh();
    } else{
      finishSync();
    }
  }

  finishSync({double? p = 1}){
    syncWithCloudCompleted = true;
    percent = p;
    refresh();
    Future.delayed(const Duration(seconds: 3), (){
      isSyncingWithCloud = false;
      syncWithCloudCompleted = false;
      percent = null;
      refresh();
      msg = "";
    });
  }

  CnHomepage(BuildContext context){
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  }

  void refresh({bool refreshSpotifyBar = false}){
    notifyListeners();
    if(refreshSpotifyBar){
      Future.delayed(const Duration(milliseconds: 500), (){
        cnSpotifyBar.refresh();
      });
    }
  }
}

// class CustomCupertinoPageRoute<T> extends CupertinoPageRoute<T>{
//   CustomCupertinoPageRoute({
//     required WidgetBuilder builder,
//     required this.previousWidget,
//     String? title,
//     RouteSettings? settings,
//     bool maintainState = true,
//     bool fullscreenDialog = false,
//   }) : super(
//     builder: builder,
//     title: title,
//     settings: settings,
//     maintainState: maintainState,
//     fullscreenDialog: fullscreenDialog,
//   );
//   final Widget previousWidget;
//   late DragStartDetails _dragStartDetails;
//   late DragUpdateDetails _dragUpdateDetails;
//
//
//   @override
//   Widget buildTransitions(
//       BuildContext context,
//       Animation<double> animation,
//       Animation<double> secondaryAnimation,
//       Widget child,
//       ) {
//
//     // final heroTransition = super.buildTransitions(
//     //   context,
//     //   animation,
//     //   secondaryAnimation,
//     //   child,
//     // );
//
//     return GestureDetector(
//       onVerticalDragStart: (details) {
//         _dragStartDetails = details;
//       },
//       onVerticalDragUpdate: (details) {
//         _dragUpdateDetails = details;
//
//         final primaryDelta = details.primaryDelta;
//         if (primaryDelta != null) {
//           final progress = primaryDelta / MediaQuery.of(context).size.height;
//           controller?.value -= progress;
//         }
//       },
//       onVerticalDragEnd: (details) {
//         controller?.reverse(from: controller?.value).then((value) => Navigator.of(context).pop());
//         // Navigator.of(context).pop();
//       },
//       child: Stack(
//         children: [
//           Container(color: Colors.black),
//           previousWidget,
//           SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0.0, 1.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: SlideTransition(
//               position: Tween<Offset>(
//                 begin: Offset.zero,
//                 end: const Offset(0.0, 1.0),
//               ).animate(secondaryAnimation),
//               child: child,
//             ),
//           ),
//         ],
//       )
//     );
//   }
// }