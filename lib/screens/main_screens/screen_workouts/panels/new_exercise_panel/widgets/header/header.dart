import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/exercise_name_field/exercise_name_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewExerciseHeader extends StatelessWidget {
  const NewExerciseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
    return SizedBox(
      height: cnNewExercise.heightHeader,
      child: const Stack(
        children: [
          ExerciseNameField(),
          CancelSaveRow(),
        ],
      ),
    );
  }
}
