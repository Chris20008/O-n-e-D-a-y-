import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/widgets/exercise_row.dart';
import 'package:flutter/material.dart';

class ExerciseRowWithLinkIcon extends StatelessWidget {
  final Exercise exercise;
  final BorderRadius? borderRadius;
  final bool hasLink;

  const ExerciseRowWithLinkIcon({
    super.key,
    required this.exercise,
    required this.borderRadius,
    required this.hasLink,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          ExerciseRow(
            exercise: exercise,
            padding: EdgeInsets.only(left: hasLink? 30 : 10, right: 10, bottom: 6, top: 3),
            margin: hasLink? const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0) : null,
            style: hasLink
                ? const TextStyle(
                fontSize: 13,
                color: Colors.white70
            )
                : null,
            borderRadius: borderRadius,
          ),
          if(exercise.blockLink)
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.link_off,
                size: 10,
                color: Color(0xFF5F9561),
              ),
            )
        ]
    );
  }
}
