import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String? exerciseNameFieldValidator ({
  required BuildContext context,
  required String? value,
  required CnNewExercisePanel cnNewExercise,
  required CnNewWorkOutPanel cnNewWorkOut
}) {
  value = value?.trim();
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.panelExEnterName;
  }
  else if(
  exerciseNameExistsInWorkout(workout: cnNewWorkOut.workout, exerciseName: cnNewExercise.exercise.name) &&
      cnNewExercise.exercise.originalName?.toLowerCase() != cnNewExercise.exercise.name.toLowerCase()
  ){
    return AppLocalizations.of(context)!.panelExAlreadyExists;
  }
  return null;
}