import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

ActionPane buildExerciseEndActionPane({
  required int index,
  required CnNewWorkOutPanel cnNewWorkout,
}) {
  return ActionPane(
    extentRatio: 0.3,
    motion: const ScrollMotion(),
    dismissible: cnNewWorkout.blockUi ? null : DismissiblePane(
      onDismissed: () {
        cnNewWorkout.dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
      },
    ),
    children: [
      SlidableAction(
        onPressed: (_) {
          cnNewWorkout.dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
        },
        backgroundColor: const Color(0xFFA12D2C),
        foregroundColor: Colors.white,
        icon: Icons.delete,
      ),
    ],
  );
}

