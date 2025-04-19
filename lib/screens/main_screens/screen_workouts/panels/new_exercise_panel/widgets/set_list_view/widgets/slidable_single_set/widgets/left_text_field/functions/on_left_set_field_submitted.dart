import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:flutter/cupertino.dart';

void onLeftSetFieldSubmitted({
  required BuildContext context,
  required String value,
  required int index,
  required CnNewExercisePanel cnNewExercise,
  required double insetsBottom,
  required double screenHeight
}) {
  /// Handle if tutorial
  if(tutorialIsRunning){
    if(value.isNotEmpty){
      FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
    }
    else{
      FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][0]);
    }
  }

  /// Handle if not tutorial
  else{
    FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
    onTapField(
        index: index,
        insetsBottom: insetsBottom,
        weightOrAmountIndex: 1,
        screenHeight: screenHeight,
        cnNewExercise: cnNewExercise
    );
  }
}