import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';

ActionPane? buildSetEndActionPane({
  required int index,
  required CnNewExercisePanel cnNewExercise
  }) {
  if (cnNewExercise.exercise.sets.length <= 1) return null;

  return ActionPane(
    extentRatio: 0.3,
    motion: const ScrollMotion(),
    dismissible: DismissiblePane(
      onDismissed: () => cnNewExercise.dismissSet(index),
    ),
    children: [
      SlidableAction(
        flex: 10,
        onPressed: (_) => cnNewExercise.dismissSet(index),
        backgroundColor: const Color(0xFFA12D2C),
        foregroundColor: Colors.white,
        icon: Icons.delete,
      ),
    ],
  );
}
