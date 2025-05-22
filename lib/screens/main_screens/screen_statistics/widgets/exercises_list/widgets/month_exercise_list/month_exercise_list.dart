import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../exercises_list.dart';
import 'single_day.dart';

class MonthExerciseList extends StatelessWidget {
  final MonthGroupedExercises groupedExercises;

  const MonthExerciseList({
    super.key,
    required this.groupedExercises
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Theme.of(context).cardColor,
          color: Colors.black.withValues(alpha: 0.5),
          // gradient: LinearGradient(
          //     begin: Alignment.bottomLeft,
          //     end: Alignment.topRight,
          //     colors: [
          //       Theme.of(context).primaryColor,
          //       Theme.of(context).cardColor,
          //     ]
          //     // colors: [
          //     //   Color(0xff2a1a0a),
          //     //   Color(0xff633e14),
          //     // ]
          // )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              DateFormat("MMMM y").format(groupedExercises.exercises.first.date),
              textScaler: const TextScaler.linear(1.1),
            ),
          ),
          for(ExerciseWithDate ex in groupedExercises.exercises)
            SingleDay(
                exercise: ex
            )
        ],
      ),
    );
  }
}
