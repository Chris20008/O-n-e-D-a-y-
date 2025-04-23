import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/cancel_save_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/workout_date_picker.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/sickdays_date_picker.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/link_button.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/workout_name_field.dart';

class NewWorkoutHeader extends StatelessWidget {
  final bool tutorialIsRunning;
  final int currentTutorialStep;

  const NewWorkoutHeader({
    required this.tutorialIsRunning,
    required this.currentTutorialStep,
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 7),
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height:50),
              if (!cnNewWorkout.isSickDays)
                Row(
                  children: [
                    const Expanded(
                      child: WorkoutNameField()
                    ),
                    const SizedBox(width: 5,),
                    if(cnNewWorkout.workout.isTemplate)
                      const LinkButton()
                  ],
                )
              else if(cnNewWorkout.isSickDays)
                const SickdaysDatePicker(),

              if(!cnNewWorkout.workout.isTemplate && !cnNewWorkout.isSickDays)
                const WorkoutDatePicker(),

              if(cnNewWorkout.workout.isTemplate)
                Container(
                  height: 25,
                  color: CupertinoTheme.of(context).scaffoldBackgroundColor
                ),
            ],
          ),
        ),
        const CancelSaveRow()
      ],
    );
  }
}