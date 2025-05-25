import 'package:fitness_app/screens/other_screens/all_exercises_panel/all_exercises_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllExercisesSearchBar extends StatelessWidget {
  const AllExercisesSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    CnAllExercisesPanel cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: viewInsets-40.clamp(-10, viewInsets),
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.only(bottom: 40),
        child: Container(
          height: 60,
          width: double.maxFinite,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(10),
          child: CupertinoSearchTextField(
            controller: cnAllExercisesPanel.textController,
            style: const TextStyle(color: Colors.white),
            backgroundColor: Theme.of(context).cardColor,
            onChanged: (value){
              cnAllExercisesPanel.scrollController.jumpTo(0);
              cnAllExercisesPanel.filterExercises(value);
            },
          ),
        ),
      ),
    );
  }
}
