import 'package:fitness_app/objects/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

ActionPane buildExerciseStartActionPane({
  required Exercise exercise,
  required Function onTapChangeLinkState,
  required Function onTapCopy
}) {
  return ActionPane(
    motion: const StretchMotion(),
    children: [
      SlidableAction(
        padding: const EdgeInsets.all(0),
        onPressed: (context) async => await onTapChangeLinkState(),
        backgroundColor: const Color(0xFF5F9561),
        foregroundColor: Colors.white,
        icon: exercise.blockLink? Icons.link : Icons.link_off,
      ),
      SlidableAction(
        padding: const EdgeInsets.all(0),
        onPressed: (context) async => await onTapCopy(),
        backgroundColor: const Color(0xFF617EB1),
        foregroundColor: Colors.white,
        icon: Icons.copy,
      ),
    ],
  );
}