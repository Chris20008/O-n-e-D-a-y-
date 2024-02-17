import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
        useMaterial3: true,
      ),
      home: MultiProvider(
          providers:[
            ChangeNotifierProvider(create: (context) => CnBottomMenu()),
            ChangeNotifierProvider(create: (context) => CnNewWorkOutPanel()),
            ChangeNotifierProvider(create: (context) => CnNewExercisePanel()),
          ],
          child: const MyHomePage(title: 'Flutter Demo Home Page')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Container(
        child: const Column(
          children: [
            Expanded(child: ScreenWorkout()),
            // const BottomMenu(),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(),
      // Column(
      //   children: [
          // Expanded(
          //     child: Container()
          // ),
          // BottomMenu()
        // ],
      // )
    );
  }
}
