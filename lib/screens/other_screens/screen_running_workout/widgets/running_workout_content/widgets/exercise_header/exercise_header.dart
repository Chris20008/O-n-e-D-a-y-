import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/widgets/grouped_exercise_header.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/widgets/rest_in_seconds_selector.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/widgets/seat_level_selector.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/widgets/set_header_row.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/widgets/single_exercise_header.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';

class ExerciseHeader extends StatelessWidget {
  final Exercise? exercise;
  final GroupedExercise? exerciseGroup;
  final String? currentSelectedExerciseName;
  final Function(String) onChangeSelectedExercise;

  const ExerciseHeader({
    super.key,
    required this.exercise,
    required this.exerciseGroup,
    required this.currentSelectedExerciseName,
    required this.onChangeSelectedExercise
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 20;
    const style = TextStyle(color: Colors.white, fontSize: 15);

    if(exercise == null){
      return const SizedBox();
    }

    return GestureDetector(
      /// Empty long press to prevent dragging
      onLongPress: (){},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (exercise?.linkName != null)
            Align(
              alignment: Alignment.centerLeft,
              child: OverflowSafeText(
                exercise!.linkName!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70
                ),
                minFontSize: 12,
                maxLines: 1,
              ),
            ),

          /// Single Exercise
          if(exerciseGroup == null)
            Row(
              children: [
                SingleExerciseHeader(exercise: exercise!),
                const SizedBox()
              ],
            )
          /// Exercise Selector
          else
            Row(
              children: [
                GroupedExerciseHeader(
                    exercise: exercise!,
                    exerciseGroup: exerciseGroup!,
                    currentSelectedExerciseName: currentSelectedExerciseName!,
                    onTap: onChangeSelectedExercise
                ),
                const Spacer(),
              ],
            ),

          const SizedBox(height: 5),

          SeatLevelSelectorRunningWorkout(
              exercise: exercise!,
              iconSize: iconSize,
              style: style
          ),

          /// Rest in Seconds Row and Selector
          RestInSecondsSelectorRunningWorkout(
              exercise: exercise!,
              iconSize: iconSize,
              style: style
          ),

          const SizedBox(height: 15),

          /// Text for Set, Template, Weight and Amount
          SetHeaderRow(exercise: exercise!),

          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
