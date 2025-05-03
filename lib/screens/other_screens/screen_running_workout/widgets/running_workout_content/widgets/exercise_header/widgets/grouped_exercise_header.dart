import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../../../../../objects/exercise.dart';

class GroupedExerciseHeader extends StatelessWidget {
  final Exercise exercise;
  final GroupedExercise exerciseGroup;
  final String currentSelectedExerciseName;
  final Function(String) onTap;
  const GroupedExerciseHeader({
    super.key,
    required this.exercise,
    required this.exerciseGroup,
    required this.currentSelectedExerciseName,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      buttonAnchor: PullDownMenuAnchor.start,
      routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
      itemBuilder: (context) {
        final children = exerciseGroup.exercises.map<PullDownMenuItem>((Exercise value) {
          return PullDownMenuItem.selectable(
            title: value.name,
            // selected: value.name == exerciseGroup.getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!)?.name,
            selected: value.name == currentSelectedExerciseName,
            onTap: () => onTap(value.name),
          );
        }).toList();
        return children;
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width-120
                ),
                child: OverflowSafeText(
                    exercise.name,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    maxLines: 1
                ),
              ),
              const SizedBox(width: 10,),
              trailingChoice(size: 15, color: Colors.white)
            ],
          )
      ),
    );
  }
}
