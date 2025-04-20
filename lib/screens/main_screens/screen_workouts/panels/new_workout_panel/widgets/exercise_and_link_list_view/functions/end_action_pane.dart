import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

ActionPane buildEndActionPane({
  // required int index,
  // required CnNewWorkOutPanel cnNewWorkout,
  required Function onDismissed
}) {
  return ActionPane(
    extentRatio: 0.3,
    motion: const ScrollMotion(),
    // dismissible: cnNewWorkout.blockUi ? null : DismissiblePane(
    //   onDismissed: () {
    //     onDismissed();
    //     // cnNewWorkout.dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
    //   },
    // ),
    dismissible: DismissiblePane(
      onDismissed: () => onDismissed()
    ),
    children: [
      SlidableAction(
        onPressed: (_) => onDismissed(),
        backgroundColor: const Color(0xFFA12D2C),
        foregroundColor: Colors.white,
        icon: Icons.delete,
      ),
    ],
  );
}

