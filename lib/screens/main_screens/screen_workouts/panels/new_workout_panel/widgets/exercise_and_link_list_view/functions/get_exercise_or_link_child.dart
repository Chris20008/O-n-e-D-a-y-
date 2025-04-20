import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/functions/tap_change_link_state.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/exercise_with_slide_action.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/link_with_slide_action.dart';
import 'package:fitness_app/widgets/fade_in_widget.dart';
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

  final groupIndex = cnNewWorkout.exercisesAndLinks.indexWhere((element) =>
    (element.linkName == item.linkName && element.linkName != null) ||
      (item.isExercise && element.name == item.name)
  );

  print("Exercise or link ${item.isExercise? item.exercise!.name : item.linkName}");
  print("Group Index $groupIndex");

  /// return Exercise
  if(item.isExercise) {
    return FadeInWidget(
      key: index == 0 && tutorialIsRunning? cnNewWorkout.keyFirstExercise : ValueKey(item.exercise!.name),
      doFadeIn: !cnNewWorkout.panelHasFullyOpened,
      delay: groupIndex*50,
      child: ExerciseWithSlideAction(
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
      ),
    );
  }

  ///return link
  else if(item.isLink) {
    return FadeInWidget(
      key: ValueKey(item.linkName),
      doFadeIn: !cnNewWorkout.panelHasFullyOpened,
      delay: groupIndex*50,
      child: LinkWithSlideAction(
        withSpacer: withSpacer,
        link: item,
        heightSpacerExerciseRow: cnNewWorkout.heightSpacerExerciseRow,
        onDismissed: (){
          cnNewWorkout.dismissLink(item);
        },
        withSlideActions: cnNewWorkout.panelHasFullyOpened,
      ),
    );
  }

  return const SizedBox();
}