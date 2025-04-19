
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';

Future onRightSetFieldSubmitted({
  required BuildContext context,
  required String value,
  required int index,
  required CnNewExercisePanel cnNewExercise,
  required CnHomepage cnHomepage,
  required double insetsBottom,
  required double screenHeight
}) async{

  /// Handle if tutorial
  if(tutorialIsRunning){
    if(value.isNotEmpty && cnNewExercise.controllers[index][0].text.isNotEmpty){
      cnHomepage.tutorial?.next();
      blockUserInput(context);
    }
    else{
      FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
    }
  }

  /// Handle if not tutorial
  else{
    if (index < cnNewExercise.exercise.sets.length - 1) {
      FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index + 1][0]);
      await onTapField(
          index: index+1,
          insetsBottom: insetsBottom,
          weightOrAmountIndex: 0,
          screenHeight: screenHeight,
          cnNewExercise: cnNewExercise
      );
    } else {
      FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
      cnNewExercise.addSet(
          screenHeight: screenHeight,
          insetsBottom: insetsBottom
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async{
        FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index + 1][0]);
        await onTapField(
            index: index +1,
            insetsBottom: insetsBottom,
            weightOrAmountIndex: 0,
            screenHeight: screenHeight,
            cnNewExercise: cnNewExercise
        );
      });
    }
  }
}