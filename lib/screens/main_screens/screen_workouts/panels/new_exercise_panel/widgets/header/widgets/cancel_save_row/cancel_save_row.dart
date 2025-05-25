import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row/child_left.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/cancel_save_row/child_middle.dart';
import 'package:fitness_app/widgets/panel_header_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'child_right.dart';

class CancelSaveRow extends StatelessWidget {
  const CancelSaveRow({super.key});

  @override
  Widget build(BuildContext context) {

    return const PanelHeaderRow(
        childLeft: ChildLeft(),
        childMiddle: ChildMiddle(),
        childRight: ChildRight()
    );
  }
}
