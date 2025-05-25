import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/set_list_view.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/new_exercise/widgets/child_left_header_row.dart';
import 'package:flutter/material.dart';

import '../../../../main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/new_exercise_header.dart';

class NewExercise extends StatelessWidget {

  const NewExercise({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: const Stack(
        children: [
          SetListView(),
          NewExerciseHeader(
            childLeft: ChildLeftHeaderRow(),
          ),
        ],
      ),
    );
  }
}
