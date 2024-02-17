import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenWorkout extends StatefulWidget {
  const ScreenWorkout({super.key});

  @override
  State<ScreenWorkout> createState() => _ScreenWorkoutState();
}

class _ScreenWorkoutState extends State<ScreenWorkout> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                iconSize: 30,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10) ))
                ),
                onPressed: () {
                  cnNewWorkout.openPanel();
                  // cnBottomMenu.setVisibility(false);
                },
                icon: const Icon(
                    Icons.add
                )
            ),
            Container(height: 5)
          ],
        ),
        const NewWorkOutPanel(),
        const NewExercisePanel(),
      ],
    );
  }
}
