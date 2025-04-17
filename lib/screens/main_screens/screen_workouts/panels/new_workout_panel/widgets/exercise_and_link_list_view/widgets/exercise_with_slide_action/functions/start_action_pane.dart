import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tap_change_link_state.dart';

ActionPane buildExerciseStartActionPane({
  required int index,
  required CnNewWorkOutPanel cnNewWorkout,
}) {
  return ActionPane(
    motion: const StretchMotion(),
    children: [
      SlidableAction(
        padding: const EdgeInsets.all(0),
        onPressed: (BuildContext context) async{
          await tapChangeLinkState(index, context, cnNewWorkout);
          cnNewWorkout.refresh();
        },
        backgroundColor: const Color(0xFF5F9561),
        foregroundColor: Colors.white,
        icon: cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink? Icons.link : Icons.link_off,
      ),
      SlidableAction(
        padding: const EdgeInsets.all(0),
        onPressed: (BuildContext context){
          cnNewWorkout.openExercise(cnNewWorkout.exercisesAndLinks[index].exercise!, copied: true, context: context);
        },
        backgroundColor: const Color(0xFF617EB1),
        foregroundColor: Colors.white,
        icon: Icons.copy,
      ),
    ],
  );
}