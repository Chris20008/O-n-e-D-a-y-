import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';

Future onExerciseNameFieldSubmitted ({
  required BuildContext context,
  required String? value,
  required CnHomepage cnHomepage,
  required CnNewExercisePanel cnNewExercise
}) async{
  if(tutorialIsRunning){
    if(value != null && value.isNotEmpty){
      cnHomepage.tutorial?.next();
      blockUserInput(context);
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
  else{
    FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][0]);
    await onTapField(
        index: 0,
        insetsBottom: 0,
        screenHeight: MediaQuery.of(context).size.height,
        weightOrAmountIndex: 0,
        cnNewExercise: cnNewExercise,
        scrollDelay: 50
    );
  }
}