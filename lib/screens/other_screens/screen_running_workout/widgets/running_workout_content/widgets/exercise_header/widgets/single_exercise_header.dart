import 'package:flutter/material.dart';
import '../../../../../../../../objects/exercise.dart';
import '../../../../../../../../util/constants.dart';

class SingleExerciseHeader extends StatelessWidget {
  final Exercise exercise;
  const SingleExerciseHeader({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width-80
        ),
        child: OverflowSafeText(
          exercise.name,
          maxLines: 1,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
