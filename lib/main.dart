import 'package:fitness_app/screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/objectbox/object_box.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(create: (context) => CnNewWorkOutPanel()),
        ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
        ChangeNotifierProvider(create: (context) => CnRunningWorkout()),
        ChangeNotifierProvider(create: (context) => CnWorkoutHistory()),
        ChangeNotifierProvider(create: (context) => CnHomepage()),
        ChangeNotifierProvider(create: (context) => CnStandardPopUp()),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        // title: 'Flutter Demo',
        darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
            useMaterial3: true,
            splashFactory: InkSparkle.splashFactory
        ),
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
        //   useMaterial3: true,
        // ),
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
  late CnHomepage cnHomepage;

  @override
  void initState() {
    initObjectBox();
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
          child: Stack(
            children: [
              AnimatedCrossFade(
                  firstChild: ScreenWorkoutHistory(key: UniqueKey()),
                  secondChild: ScreenWorkout(key: UniqueKey()),
                  crossFadeState: cnBottomMenu.index == 0?
                  CrossFadeState.showFirst:
                  CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200)
              ),
              const NewWorkOutPanel(),
              const NewExercisePanel(),
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

  void refresh(){
    notifyListeners();
  }
}