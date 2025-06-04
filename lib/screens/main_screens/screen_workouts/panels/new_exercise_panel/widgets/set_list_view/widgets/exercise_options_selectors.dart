import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseOptionsSelectors extends StatefulWidget {
  const ExerciseOptionsSelectors({super.key});

  @override
  State<ExerciseOptionsSelectors> createState() => _ExerciseOptionsSelectorsState();
}

class _ExerciseOptionsSelectorsState extends State<ExerciseOptionsSelectors> {

  late CnNewExercisePanel cnNewExercise;

  @override
  Widget build(BuildContext context) {

    cnNewExercise = context.read<CnNewExercisePanel>();
    CnNewWorkOutPanel cnNewWorkOut = Provider.of<CnNewWorkOutPanel>(context);

    return CupertinoListSection.insetGrouped(
      key: cnNewExercise.getKeyHeader(context),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      children: [
        /// Rest in Seconds Row and Selector
        Selector<CnNewExercisePanel, int>(
            selector: (_, cn) => cn.exercise.restInSeconds,
            builder: (_, __, ___){
            return cnNewExercise.getRestInSecondsSelector(
                context: context,
                // refresh: () => setState(() {})
            );
          }
        ),

        /// Seat Level Row and Selector
        Selector<CnNewExercisePanel, int?>(
            selector: (_, cn) => cn.exercise.seatLevel,
            builder: (_, __, ___){
            return cnNewExercise.getSeatLevelSelector(
                context: context,
                // refresh: () => setState(() {})
            );
          }
        ),

        /// Exercise Category Selector
        Selector<CnNewExercisePanel, int>(
            selector: (_, cn) => cn.exercise.category,
            builder: (_, __, ___){
            return cnNewExercise.getExerciseCategorySelector(
                context: context,
                isTemplate: cnNewExercise.exercise.isNewExercise(),
            );
          }
        ),

        /// Body Weight selector
        Selector<CnNewExercisePanel, double>(
            selector: (_, cn) => cn.exercise.bodyWeightPercent,
            builder: (_, __, ___){
            return cnNewExercise.getBodyWeightPercentSelector(
                context: context,
                isTemplate: cnNewExercise.exercise.isNewExercise() || cnNewWorkOut.workout.isTemplate,
                refresh: () => setState(() {})
            );
          }
        ),

        if(cnNewExercise.linkedExercises.isNotEmpty)
          Selector<CnNewExercisePanel, String?>(
              selector: (_, cn) => cn.exercise.linkName,
              builder: (_, __, ___){
              return cnNewExercise.getSelectLink();
            }
          )
      ],
    );
  }
}
