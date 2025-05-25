import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import '../../../../../../../other_screens/all_exercises_panel/all_exercises_panel.dart';

class AddExerciseButton extends StatelessWidget {
  final bool tutorialIsRunning;
  final int currentTutorialStep;

  const AddExerciseButton({
    required this.tutorialIsRunning,
    required this.currentTutorialStep,
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    final CnAllExercisesPanel cnAllExercisesPanel = Provider.of<CnAllExercisesPanel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(
          top: 10,
      ),
      child: getRowButton(
        key: cnNewWorkout.keyAddExercise,
        context: context,
        minusWidth: 0,
        onPressed: () async{
          if(MediaQuery.of(context).viewInsets.bottom > 0){
            FocusManager.instance.primaryFocus?.unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
          }
          cnAllExercisesPanel.openPanel();
        },
      ),
    );
  }
}