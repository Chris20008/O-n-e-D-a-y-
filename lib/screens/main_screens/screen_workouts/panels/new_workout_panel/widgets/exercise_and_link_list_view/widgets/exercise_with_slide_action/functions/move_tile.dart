import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/gestures.dart';

Future moveTile({
  required double startY,
  required double endY,
  required CnNewWorkOutPanel cnNewWorkout
}) async{
  cnNewWorkout.blockUi = true;
  cnNewWorkout.refresh();

  const int pointer = 1000000;

  /// Start drag
  GestureBinding.instance.handlePointerEvent(
    PointerDownEvent(position: Offset(100, startY), pointer: pointer),
  );

  await Future.delayed(const Duration(milliseconds: 600));

  /// Move drag
  int steps = 35;
  final delta =  (endY - startY)/steps;
  for (int i = 1; i <= steps; i++) {
    GestureBinding.instance.handlePointerEvent(
      PointerMoveEvent(delta: Offset(0, delta), pointer: pointer),
    );

    await Future.delayed(const Duration(milliseconds: 6));
  }

  /// Stop drag
  GestureBinding.instance.handlePointerEvent(
    PointerUpEvent(position: Offset(100, endY), pointer: pointer),
  );

  await Future.delayed(const Duration(milliseconds: 300));

  cnNewWorkout.blockUi = false;
  cnNewWorkout.refresh();
}