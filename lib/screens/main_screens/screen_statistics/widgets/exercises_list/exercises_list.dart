import 'dart:async';

import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/exercises_list/widgets/month_exercise_list/month_exercise_list.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../objects/exercise.dart';
import '../../../../../../../widgets/scroll_listener.dart';
import '../../screen_statistics.dart';

class ExercisesList extends StatelessWidget {
  const ExercisesList({super.key});

  @override
  Widget build(BuildContext context) {
    late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
    bool doAnimate = true;
    Timer? timer = Timer(const Duration(milliseconds: 300), () => doAnimate = false);

    List<ExerciseWithDate> exercises = (cnScreenStatistics.getSelectedExerciseHistory()?? {}).entries
        .map((entry) => ExerciseWithDate(
        exercise: Exercise.fromObExercise(entry.value),
        date: entry.key)
    ).toList().reversed.toList();

    final List<MonthGroupedExercises> groupedExercises = [];

    for(ExerciseWithDate ex in exercises){
      if(groupedExercises.isEmpty || !groupedExercises.last.date.isSameMonth(ex.date)){
        groupedExercises.add(MonthGroupedExercises(date: ex.date, ex: ex));
      }
      else{
        groupedExercises.last.exercises.add(ex);
      }
    }
    
    return Expanded(
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: cnScreenStatistics.scrollController.controller,
          itemCount: groupedExercises.length + 1,
          itemBuilder: (context, index){
            if (index == 0){
              return ScrollListener(
                  minValue: 0,
                  maxValue: cnScreenStatistics.heightExerciseLineChartMax,
                  controller: cnScreenStatistics.scrollController.controller,
                  inverted: true,
                  builder: (context, value, percent) {
                    return SizedBox(height: value);
                  }
              );
            }
            return MonthExerciseList(
                groupedExercises: groupedExercises[index-1],
                index: index,
                doAnimate: doAnimate
            );
          }
      ),
    );
  }
}

class MonthGroupedExercises{
  DateTime date;
  List<ExerciseWithDate> exercises = [];

  MonthGroupedExercises({
    required this.date,
    required ExerciseWithDate ex,
  }){
   exercises.add(ex);
  }
}

class ExerciseWithDate{
  final Exercise exercise;
  final DateTime date;

  ExerciseWithDate({
    required this.exercise,
    required this.date,
  });
}