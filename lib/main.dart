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
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/widgets/background_image.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_add_workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

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
        // ChangeNotifierProvider(create: (context) => CnConfig()),
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
        ChangeNotifierProvider(create: (context) => CnBackgroundImage()),
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
        // locale: const Locale("de"),
        supportedLocales: const [
          Locale('en'), /// English
          Locale('de'), /// German
        ],
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

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
  late final AnimationController _animationControllerWorkoutPanel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final AnimationController _animationControllerSettingPanel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
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
    _animationControllerWorkoutPanel.dispose();
    _animationControllerSettingPanel.dispose();
    super.dispose();
  }

  void setIntroScreen(){
    currentTutorialStep = cnConfig.currentTutorialStep;
    print("Current tutorial step $currentTutorialStep");
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
    await Future.delayed(Duration(milliseconds: Platform.isAndroid? 100 : 700));
    await cnConfig.initData();
    await dotenv.load(fileName: "dotenv.env");
    if(cnConfig.config.settings["languageCode"] == null){
      if(context.mounted){
        final res = await findSystemLocale();
        MyApp.of(context)?.setLocale(languageCode: res);
        // cnConfig.setLanguage(Localizations.localeOf(context).languageCode);
      }
    }
    else if(context.mounted && cnConfig.config.settings["languageCode"] != null){
        MyApp.of(context)?.setLocale(languageCode: cnConfig.config.settings["languageCode"]);
    }
    cnRunningWorkout.initCachedData(cnConfig.config.cnRunningWorkout);
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnScreenStatistics.init(cnConfig.config.cnScreenStatistics);
    cnWorkouts.animationControllerWorkoutPanel = _animationControllerWorkoutPanel;
    cnScreenStatistics.animationControllerSettingPanel = _animationControllerSettingPanel;
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

    if(Platform.isAndroid && cnConfig.syncWithCloud){
      await Future.delayed(const Duration(milliseconds: 200), () async {
        await cnConfig.signInGoogleDrive();
      });
    }
    setState(() {
      mainIsInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    cnHomepage = Provider.of<CnHomepage>(context);

    /// Screen to bee shown until 'await cnConfig.initData();' is finished
    /// So the config data is been initialized
    if(!mainIsInitialized){
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
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(child: CircularProgressIndicator())
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
      print("START TUT ONE");
      tutorialIsRunning = true;
      initTutorialAddWorkout(context);
      showTutorialAddWorkout(context);
    }
    print("is running $tutorialIsRunning");

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
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if(cnBottomMenu.index != 2)
                  Stack(
                    children: [
                      /// Animiated Builder to Reduce Size of left and middle screen when workout panel is opened
                      AnimatedBuilder(
                        animation: _animationControllerWorkoutPanel,
                        builder: (context, child) {
                          double scale = 1.0 - (_animationControllerWorkoutPanel.value * (Platform.isAndroid? 0.15 : 0.2));
                          double borderRadius = 26 - (scale*10-9)*20;
                          borderRadius = borderRadius > 25 ? 25 : borderRadius;
                          return Transform.scale(
                            scale: scale,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(borderRadius),
                                child: child
                            ),
                          );
                        },
                        child: AnimatedCrossFade(
                            firstChild: const ScreenWorkoutHistory(),
                            secondChild: const ScreenWorkout(),
                            crossFadeState: cnBottomMenu.index == 0?
                            CrossFadeState.showFirst:
                            CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 200)
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

                      /// Overlay with opacity, when workout panel is opened
                      /// We use this instead of the panel own backdropEnabled feature, because
                      /// we scale down the sizes of the workout panel when the exercise panel is opened
                      /// However the backdrop of the workout panel would be scaled down as well
                      /// so we use this AnimatedBuilder which is not scaled down, to provide a
                      /// backdrop while the workout panel is opened
                      IgnorePointer(
                        ignoring: true,
                        child: AnimatedBuilder(
                          animation: _animationControllerWorkoutPanel,
                          builder: (BuildContext context, Widget? child) {
                            double opacity = _animationControllerWorkoutPanel.value;
                            /// Scales the opacity from 0 -> 0.5 when animationController is between 0 - 0.5
                            /// And back from 0.5 - > 0 when animationController is between 0.5 - 1
                            /// We do that, because on exercise panel the backdropEnabled is True, so we don't
                            /// need this anymore when exercise panel is opened because it would become to dark
                            /// with backdrop AND this AnimatedBuilder together
                            opacity = opacity > 0.5 ? 1 - opacity : opacity;
                            return Container(
                              color: Colors.black.withOpacity(opacity),
                            );
                          },
                        ),
                      ),
                      AnimatedBuilder(
                          animation: _animationControllerWorkoutPanel,
                          builder: (context, child) {
                            double scale = 1.0 - (_animationControllerWorkoutPanel.value * 0.2) + (0.5 * 0.2);
                            scale = scale > 1 ? 1 : scale;
                            double topPadding = -(_animationControllerWorkoutPanel.value-0.5)*110;
                            topPadding = topPadding > 0 ? 0 : topPadding;
                            // print("TOP PADDING: $topPadding");
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 0),
                              transform: Matrix4.translationValues(0, topPadding, 0),
                              child: Transform.scale(
                                scale: scale,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30 -  (scale*10-9)*25),
                                    child: child
                                ),
                              ),
                            );
                          },
                          child: const NewWorkOutPanel()
                      ),
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
                // ElevatedButton(
                //     onPressed: (){
                //       getLastFilename(cnConfig);
                //     },
                //     child: Text("TEST")
                // )
              ],
            ),
        ),
      ),
    );
  }

  void onFinishWelcomeScreen(bool doShowTutorial){
    cnConfig.setWelcomeScreen(false);
    setState(() {
      closeWelcomeScreen = true;
    });
    Future.delayed(const Duration(milliseconds: 500), (){
      setState(() {
        cnBottomMenu.showBottomMenuAnimated();
        if(doShowTutorial && currentTutorialStep == 0) {
          initTutorialAddWorkout(context);
          showTutorialAddWorkout(context);
        }
        showWelcomeScreen = false;
      });
    });
  }
}

class CnHomepage extends ChangeNotifier {
  late CnSpotifyBar cnSpotifyBar;

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