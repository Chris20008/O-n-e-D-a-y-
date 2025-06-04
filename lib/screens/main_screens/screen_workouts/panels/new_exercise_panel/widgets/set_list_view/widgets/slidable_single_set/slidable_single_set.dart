import 'dart:io';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/widgets/left_text_field/left_text_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/widgets/right_text_field/right_text_field.dart';
import 'package:fitness_app/widgets/block_swipe_back.dart';
import 'package:fitness_app/widgets/set_type_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'functions/end_action_pane.dart';

class SlidableSingleSet extends StatelessWidget {

  final int index;
  final double insetsBottom;
  final double screenHeight;
  final CnHomepage cnHomepage;
  final CnNewExercisePanel cnNewExercise;

  const SlidableSingleSet({
    super.key,
    required this.index,
    required this.insetsBottom,
    required this.screenHeight,
    required this.cnHomepage,
    required this.cnNewExercise
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: Platform.isAndroid? const EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.zero,
      child: BlockGesture(
        withPadding: true,
        child: Slidable(
            key: key,
            endActionPane: buildSetEndActionPane(index: index, cnNewExercise: cnNewExercise),
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Selector<CnNewExercisePanel, int?>(
                      selector: (_, cn) => cn.exercise.sets[index].setType,
                      builder: (_, __, ___){
                      return SetTypeSelector(
                          index: index,
                          set: cnNewExercise.exercise.sets[index],
                          width: 50,
                          onConfirm: () => cnNewExercise.refresh()
                      );
                    }
                  ),

                  /// Weight
                  LeftTextField(
                      index: index,
                      insetsBottom: insetsBottom,
                      screenHeight: screenHeight,
                      cnNewExercise: cnNewExercise
                  ),

                  /// Amount
                  RightTextField(
                      index: index,
                      insetsBottom: insetsBottom,
                      screenHeight: screenHeight,
                      cnHomepage: cnHomepage,
                      cnNewExercise: cnNewExercise
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
