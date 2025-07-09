import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../exercises_list.dart';
import 'single_day.dart';

class MonthExerciseList extends StatelessWidget {
  final MonthGroupedExercises groupedExercises;
  final int index;
  final bool doAnimate;

  const MonthExerciseList({
    super.key,
    required this.groupedExercises,
    required this.index,
    required this.doAnimate
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              DateFormat("MMMM y", Localizations.localeOf(context).languageCode).format(groupedExercises.exercises.first.date),
              textScaler: const TextScaler.linear(1.1),
            ),
          ),
          for(int i in List.generate(groupedExercises.exercises.length, (i) => i))
            FadeInRight(
                delay: Duration(milliseconds: doAnimate? (i * 75) : 0),
                duration: Duration(milliseconds: doAnimate? 300 : 0),
                child:SingleDay(
                    exercise: groupedExercises.exercises[i]
                )
            ),
          // for(ExerciseWithDate ex in groupedExercises.exercises)
          //   SingleDay(
          //       exercise: ex
          //   )
        ],
      ),
    );
  }
}
