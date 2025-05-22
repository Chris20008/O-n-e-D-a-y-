import 'dart:async';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/animated_column.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/stopwatch.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/wrapper_screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/welcome_screen.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/language_config.dart';
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/widgets/all_exercises_panel/all_exercises_panel.dart';
import 'package:fitness_app/widgets/background_image.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:fitness_app/widgets/show_new_features_pop_up.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_create_workout_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:package_info_plus/package_info_plus.dart';

late ObjectBox objectbox;
bool tutorialIsRunning = false;
int currentTutorialStep = 0;
String pictureAssetPath = "lib/assets/pictures/";
Color buttonTextColor = const Color(0xffdb7b01);

void main() {

  // debugRepaintRainbowEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
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

class MyAppState extends State<MyApp>{
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
    setIntlLanguage();
  }

  @override
  Widget build(BuildContext context) {
    pr("Main");
    return MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnBannerRunningWorkout()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
        ChangeNotifierProvider(create: (context) => CnBackgroundColor()),
        ChangeNotifierProvider(create: (context) => CnAnimatedColumn()),
        ChangeNotifierProvider(create: (context) => CnWorkouts()),
        ChangeNotifierProvider(create: (context) => CnBottomMenu()),
        ChangeNotifierProvider(create: (context) => CnConfig()),
        ChangeNotifierProvider(create: (context) => CnSelectorExerciseToUpdate()),
        ChangeNotifierProvider(create: (context) => CnAllExercisesPanel()),
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
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.iOS: MyTransition(),
              TargetPlatform.android: MyTransition(),
            }),
            cardColor: const Color(0xFF2C2C2E),
            primaryColor: const Color(0xFF1C1C1E),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
            // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            // useMaterial3: true,
            splashFactory: InkSparkle.splashFactory,
            cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: Color(0xffdb7b01),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xffdb7b01),
            ),
        ),
        // Lokalisierung (funktioniert auch in CupertinoApp!)
        // locale: _locale,
        // supportedLocales: supportedLocales,
        // localizationsDelegates: const [
        //   AppLocalizations.delegate,
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalCupertinoLocalizations.delegate,
        // ],
        //
        // // Theme
        // theme: const CupertinoThemeData(
        //   brightness: Brightness.dark,
        //   primaryColor: Color(0xffdb7b01),
        //   barBackgroundColor: Color(0xFF2C2C2E),
        //   scaffoldBackgroundColor: Color(0xFF1C1C1E),
        //   textTheme: CupertinoTextThemeData(
        //     primaryColor: Color(0xffdb7b01),
        //   ),
        // ),
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
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnAllExercisesPanel cnAllExercisesPanel = Provider.of<CnAllExercisesPanel>(context, listen: false);
  late CnBannerRunningWorkout cnBannerRunningWorkout = Provider.of<CnBannerRunningWorkout>(context, listen: false);
  late CnConfig cnConfig;
  late CnHomepage cnHomepage;
  bool showWelcomeScreen = false;
  bool closeWelcomeScreen = true;
  bool mainIsInitialized = false;

  @override
  void initState() {
    /// Init Shader for PageRoute
    // Navigator.of(context).push(
    //     MaterialPageRoute(
    //         builder: (context) => const ScreenRunningWorkout()
    //     )
    // );
    // Navigator.of(context).pop();
    initMain();
    super.initState();
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
      final res = await findSystemLocale();
      if(context.mounted){
        MyApp.of(context)?.setLocale(languageCode: res);
      }
    }
    else if(context.mounted && cnConfig.config.settings["languageCode"] != null){
        MyApp.of(context)?.setLocale(languageCode: cnConfig.config.settings["languageCode"]);
    }
    cnRunningWorkout.initCachedData(cnConfig.config.cnRunningWorkout);
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnScreenStatistics.init(cnConfig.config.cnScreenStatistics, context);
    cnBottomMenu.setBottomMenuHeight(context);
    cnBottomMenu.refresh();

    /// setIntroScreen needs to be after cnBottomMenu.setBottomMenuHeight
    setIntroScreen();
    cnStopwatchWidget.countdownTime = cnConfig.countdownTime;

    /// open screenRunningWorkout when it's saved in config.json and the welcome screen is not shown
    if(cnRunningWorkout.isRunning && !showWelcomeScreen){
      if(cnRunningWorkout.isVisible){
        cnBannerRunningWorkout.onlyShow();
        Future.delayed(const Duration(milliseconds: 300), (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WrapperScreenRunningWorkout()
              ));
        });
      }
      else{
        cnBannerRunningWorkout.activateButton();
      }

    }


    /// sign in and sync with cloud
    await cnConfig.signInCloud();
    if(!showWelcomeScreen && cnConfig.syncMultipleDevices){
      trySyncWithCloud();
    }

    setState(() {
      mainIsInitialized = true;
    });

    final String version = (await PackageInfo.fromPlatform()).version;
    if(!showWelcomeScreen){
      if(version != cnConfig.version){
        await Future.delayed(const Duration(milliseconds: 500), (){});
        await showNewFeaturesPopUp(
          context: context,
          cnScreenStatistics: cnScreenStatistics,
          cnConfig: cnConfig
        );
        await cnConfig.setVersion(version);
      }
    } else{
      if(version != cnConfig.version){
        await cnConfig.setVersion(version);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    pr("Homepage");

    cnConfig  = Provider.of<CnConfig>(context);
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

    if(cnConfig.currentTutorialStep == 0
        && showWelcomeScreen == false
        && closeWelcomeScreen == true
        && !tutorialIsRunning
        && cnBottomMenu.index == 1
    ){
      tutorialIsRunning = true;
      initTutorialCreateWorkoutTemplate(context);
      cnHomepage.tutorial = showTutorialCreateWorkoutTemplate(context);
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const BottomMenu(),
      body: PopScope(
        canPop: false,
        child: Container(
          color: Colors.black,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [

                if(cnBottomMenu.index != 2 && !showWelcomeScreen)
                  Stack(
                    children: [
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

                      // const AllExercisesPanel(),
                    ],
                  )

                else if(!showWelcomeScreen)
                  const ScreenStatistics(),

                if(cnBottomMenu.index == 2)
                  const NewExercisePanel(),

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
                          Selector<CnBannerRunningWorkout, bool>(
                              selector: (_, cn) => cn.showBanner,
                              builder: (_, showBanner, __){
                              return AnimatedContainer(
                                height: showBanner && cnBottomMenu.index == 1? 55 : (Platform.isAndroid? 10 : 0),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            }
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withValues(alpha: 0.4)
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
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => const LocalFilePicker()
                //           ));
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
            backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
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
          initTutorialCreateWorkoutTemplate(context);
          cnHomepage.tutorial = showTutorialCreateWorkoutTemplate(context);
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

class CnHomepage extends ChangeNotifier {
  late CnSpotifyBar cnSpotifyBar;
  bool isSyncingWithCloud = false;
  bool syncWithCloudCompleted = false;
  double? percent;
  String msg = "";
  Map<String, AnimationController> animationControllers = {};
  TutorialCoachMark? tutorial;
  GlobalKey keyKeyboardTopBar = GlobalKey();

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

class MyTransition extends CupertinoPageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    const delay = Duration(milliseconds: 80);
    final totalDuration = route.transitionDuration;

    final delayFraction = delay.inMilliseconds / totalDuration.inMilliseconds;
    const pauseValue = 0.001;

    final delayedPrimary = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(pauseValue),
        weight: delayFraction,
      ),
      TweenSequenceItem(
        tween: Tween(begin: pauseValue, end: 1.0),
        weight: 1 - delayFraction,
      ),
    ]).animate(animation);

    final delayedSecondary = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: delayFraction,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1 - delayFraction,
      ),
    ]).animate(secondaryAnimation);
    return CupertinoRouteTransitionMixin.buildPageTransitions<T>(
      route,
      context,
      delayedPrimary,
      delayedSecondary,
      child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 580);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 480);
}


