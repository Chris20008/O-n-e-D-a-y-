import 'dart:async';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/screens/screen_running_workout/animated_column.dart';
import 'package:fitness_app/widgets/background_image.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:fitness_app/screens/screen_running_workout/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

late ObjectBox objectbox;

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
  final Language _language = languages[LANGUAGES.de.value];
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
        ChangeNotifierProvider(create: (context) => CnBottomMenu()),
        ChangeNotifierProvider(create: (context) => CnConfig()),
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
        ChangeNotifierProvider(create: (context) => PlayerStateStream()),
        ChangeNotifierProvider(create: (context) => CnBackgroundImage()),
        ChangeNotifierProvider(create: (context) => CnAnimatedColumn()),
        ChangeNotifierProvider(create: (context) => CnScreenStatistics()),
        ChangeNotifierProvider(create: (context) => CnWorkouts()),
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
          // AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
            useMaterial3: true,
            splashFactory: InkSparkle.splashFactory,
            cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.dark
            )
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
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: true);
  late CnHomepage cnHomepage;

  @override
  void initState() {
    initObjectBox();
    super.initState();
  }

  void initObjectBox() async{
    objectbox = await ObjectBox.create();
    await cnConfig.initData();
    await dotenv.load(fileName: "dotenv.env");
    print("LAnguage Code");
    print(cnConfig.config.languageCode);
    if(cnConfig.config.languageCode == null){
      print("IS NULL");
      if(context.mounted){
        cnConfig.setLanguage(Localizations.localeOf(context).languageCode);
      }
    } else{
      print("IS NOT NULL");
      if(context.mounted){
        MyApp.of(context)?.setLocale(languageCode: cnConfig.config.languageCode);
      }
    }
    print(cnConfig.config.languageCode);
    // MyApp.of(context)?.setLocale(language: LANGUAGES.en, config: cnConfig);
    cnRunningWorkout.initCachedData(cnConfig.config.cnRunningWorkout);
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnScreenStatistics.init();
    if(cnRunningWorkout.isRunning && cnRunningWorkout.isVisible){
      Future.delayed(const Duration(milliseconds: 300), (){
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const ScreenRunningWorkout()
            ));
        });
    }
  }

  @override
  Widget build(BuildContext context) {

    cnHomepage = Provider.of<CnHomepage>(context);
    if(cnConfig.isInitialized){
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xffc26a0e),
                    const Color(0xbb110a02)

                    // const Color(0xffb2620e)
                    // const Color(0xbb1c1003),

                    // const Color(0xff84490b),
                    // Colors.black.withOpacity(0.9),
                  ]
              )
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // ImageFiltered(
              //     imageFilter: ImageFilter.blur(
              //       sigmaX: 50.0,
              //       sigmaY: 50.0,
              //     ),
              //     child: cnSpotifyBar.lastImage
              // ),
              // const BackgroundImage(),
              // if(cnBottomMenu.index != 2)
              //   AnimatedCrossFade(
              //       firstChild: const ScreenWorkoutHistory(),
              //       secondChild: const ScreenWorkout(),
              //       crossFadeState: cnBottomMenu.index == 0?
              //       CrossFadeState.showFirst:
              //       CrossFadeState.showSecond,
              //       duration: const Duration(milliseconds: 200)
              //   )
              // else
              //   const ScreenStatistics(),
              //
              // if(cnBottomMenu.index != 2)

              if(cnBottomMenu.index != 2)
                Stack(
                  children: [
                    AnimatedCrossFade(
                        firstChild: const ScreenWorkoutHistory(),
                        secondChild: const ScreenWorkout(),
                        crossFadeState: cnBottomMenu.index == 0?
                        CrossFadeState.showFirst:
                        CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200)
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300), // Animationsdauer
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
              const StandardPopUp()
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

  CnHomepage(BuildContext context){
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
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