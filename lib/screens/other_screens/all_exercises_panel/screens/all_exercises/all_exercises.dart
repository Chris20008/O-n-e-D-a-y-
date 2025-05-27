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

    /// watch to update LetterSideBar on Panel 0 or larger 0
    /// and listen to textController changes
    CnAllExercisesPanel cnAllExercisesPanel = context.watch<CnAllExercisesPanel>();

    return Container(
      color: Theme.of(context).primaryColor,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const AllExercisesList(),

          const HeaderAllExercises(),

          /// Search Bar
          const AllExercisesSearchBar(),

          if(cnAllExercisesPanel.getPanelController(context).isAttached
              && cnAllExercisesPanel.getPanelController(context).panelPosition > 0
              && cnAllExercisesPanel.textController.text.isEmpty
          )
            const LetterSideBar(),
        ],
      ),
    );
  }
}
