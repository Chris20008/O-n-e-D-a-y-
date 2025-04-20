import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/functions/tap_change_link_state.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/exercise_with_slide_action.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/link_with_slide_action.dart';
import 'package:flutter/cupertino.dart';

Widget getExerciseOrLinkChild({
  required SlidableExerciseOrLink item,
  required int index,
  required CnNewWorkOutPanel cnNewWorkout,
  required CnNewExercisePanel cnNewExercisePanel,
  required bool isTotalLastItem,
  required bool isLastItemInGroup
}){
  final bool withSpacer = isTotalLastItem || isLastItemInGroup || !item.hasLink;

  /// return Exercise
  if(item.isExercise) {
    return ExerciseWithSlideAction(
      key: index == 0 && tutorialIsRunning? cnNewWorkout.keyFirstExercise : ValueKey(item.exercise!.name),
      exercise: item,
      withSpacer: withSpacer,
      isTotalLastItem: isTotalLastItem,
      isLastItemInGroup: isLastItemInGroup,
      heightSpacerExerciseRow: cnNewWorkout.heightSpacerExerciseRow,
      onDismissed: (){
        cnNewWorkout.dismissExercise(item);
      },
      onTap: (){
        cnNewWorkout.openExercise(item.exercise!, cnNewExercisePanel: cnNewExercisePanel);
      },
      onTapCopy: (){
        cnNewWorkout.openExercise(item.exercise!, copied: true, cnNewExercisePanel: cnNewExercisePanel);
      },
      onTapChangeLinkState: () async{
        await tapChangeLinkState(
            index: index,
            exercise: item.exercise!,
            isTotalLastItem: isTotalLastItem,
            isLastItemInGroup: isLastItemInGroup,
            cnNewWorkout: cnNewWorkout
        );
        cnNewWorkout.refresh();
      },
      withSlideActions: cnNewWorkout.panelHasFullyOpened,
    );
  }

  ///return link
  else if(item.isLink) {
    return LinkWithSlideAction(
      key: ValueKey(item.linkName),
      withSpacer: withSpacer,
      link: item,
      heightSpacerExerciseRow: cnNewWorkout.heightSpacerExerciseRow,
      onDismissed: (){
        cnNewWorkout.dismissLink(item);
      },
      withSlideActions: cnNewWorkout.panelHasFullyOpened,
    );
  }

  return const SizedBox();
}