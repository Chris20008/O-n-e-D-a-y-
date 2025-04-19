import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:flutter/material.dart';

void addExercise({
  required BuildContext context,
  required bool tutorialIsRunning,
  required CnNewWorkOutPanel cnNewWorkout,
  required CnNewExercisePanel cnNewExercisePanel,
  required int currentTutorialStep
}){
    if(!tutorialIsRunning && cnNewWorkout.panelController.panelPosition > 0.99){
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
    }
    else if(tutorialIsRunning && cnNewWorkout.panelController.isPanelOpen){
      if(currentTutorialStep < 2){
        FocusScope.of(context).unfocus();
      }
      else{
        cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
      }
    }
    else{
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
    }
  }