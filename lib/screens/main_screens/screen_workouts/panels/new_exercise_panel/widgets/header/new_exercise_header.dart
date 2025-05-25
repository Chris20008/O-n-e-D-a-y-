import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row/child_left.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row/child_middle.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row/child_right.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/exercise_name_field/exercise_name_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../../../widgets/panel_header_row.dart';

class NewExerciseHeader extends StatelessWidget {
  final Widget? childLeft;

  const NewExerciseHeader({super.key, this.childLeft});

  @override
  Widget build(BuildContext context) {
    CnNewExercisePanel cnNewExercise = context.watch<CnNewExercisePanel>();
    return SizedBox(
      height: cnNewExercise.heightHeader,
      child: Stack(
        children: [
          const ExerciseNameField(),

          PanelHeaderRow(
              childLeft: childLeft?? const ChildLeft(),
              childMiddle: const ChildMiddle(),
              childRight: const ChildRight()
          ),
        ],
      ),
    );
  }
}
