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

    cnNewExercise = Provider.of<CnNewExercisePanel>(context);
    CnNewWorkOutPanel cnNewWorkOut = Provider.of<CnNewWorkOutPanel>(context);

    return CupertinoListSection.insetGrouped(
      key: cnNewExercise.getKeyHeader(context),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      children: [
        /// Rest in Seconds Row and Selector
        cnNewExercise.getRestInSecondsSelector(
            context: context,
            // refresh: () => setState(() {})
        ),

        /// Seat Level Row and Selector
        cnNewExercise.getSeatLevelSelector(
            context: context,
            // refresh: () => setState(() {})
        ),

        /// Exercise Category Selector
        cnNewExercise.getExerciseCategorySelector(
            context: context,
            isTemplate: cnNewExercise.exercise.isNewExercise(),
            // refresh: cnNewExercise.refresh /// use refresh instead of setState to update set types, f.e. weight -> time
        ),

        /// Body Weight selector
        cnNewExercise.getBodyWeightPercentSelector(
            context: context,
            isTemplate: cnNewExercise.exercise.isNewExercise() || cnNewWorkOut.workout.isTemplate,
            refresh: () => setState(() {})
        ),

        if(cnNewExercise.linkedExercises.isNotEmpty)
          cnNewExercise.getSelectLink()
      ],
    );
  }
}
