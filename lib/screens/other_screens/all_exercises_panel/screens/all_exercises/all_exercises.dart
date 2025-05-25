import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/all_exercises_list/all_exercises_list.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/all_exercises_search_bar.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/header_all_exercises/header_all_exercises.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/letter_side_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../all_exercises_panel.dart';

class AllExercises extends StatelessWidget {

  const AllExercises({super.key,});

  @override
  Widget build(BuildContext context) {

    CnAllExercisesPanel cnAllExercisesPanel = context.read<CnAllExercisesPanel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const AllExercisesList(),

            const HeaderAllExercises(),

            /// Search Bar
            const AllExercisesSearchBar(),

            if(cnAllExercisesPanel.panelController.isAttached
                && cnAllExercisesPanel.panelController.panelPosition > 0
                && cnAllExercisesPanel.textController.text.isEmpty
            )
              const LetterSideBar()
          ],
        ),
      ),
    );
  }
}
