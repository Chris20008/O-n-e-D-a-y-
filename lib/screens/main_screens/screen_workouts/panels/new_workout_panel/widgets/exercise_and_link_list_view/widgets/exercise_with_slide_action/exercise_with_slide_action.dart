import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/functions/end_action_pane.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/widgets/exercise_row_with_link_icon.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';
import 'package:fitness_app/widgets/spacer_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'functions/start_action_pane.dart';

class ExerciseWithSlideAction extends StatelessWidget {
  // final int index;
  final SlidableExerciseOrLink exercise;
  final bool withSpacer;
  final bool isTotalLastItem;
  final bool isLastItemInGroup;
  final double heightSpacerExerciseRow;
  final Function onDismissed;
  final Function onTap;
  final Function onTapCopy;
  final Function onTapChangeLinkState;
  final bool withSlideActions;

  const ExerciseWithSlideAction({
    super.key,
    // required this.index,
    required this.exercise,
    required this.withSpacer,
    required this.isTotalLastItem,
    required this.isLastItemInGroup,
    required this.heightSpacerExerciseRow,
    required this.onDismissed,
    required this.onTap,
    required this.onTapCopy,
    required this.onTapChangeLinkState,
    required this.withSlideActions,
  });

  @override
  Widget build(BuildContext context) {

    final Widget exerciseRow = CupertinoButton(
      pressedOpacity: MediaQuery.of(context).viewInsets.bottom <= 0? 0.4 : 1,
      padding: EdgeInsets.zero,
      onPressed: (){
        if(MediaQuery.of(context).viewInsets.bottom <= 0){
          onTap();
        } else{
          FocusScope.of(context).unfocus();
        }
      },
      child: ExerciseRowWithLinkIcon(
        exercise: exercise.exercise!,
        borderRadius: getBorderRadius(
            hasLink: exercise.hasLink,
            isTotalLastItem: isTotalLastItem,
            isLastItemInGroup: isLastItemInGroup
        ),
        hasLink: exercise.hasLink,
      ),
    );

    if(!withSlideActions){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (exercise.hasLink)
            SpaceFixerHorizontalLine(
              context: context,
              overflowHeight: 2,
              width: MediaQuery.of(context).size.width - 40,
              overflowColor: CupertinoTheme.of(context).barBackgroundColor,
            ),
          Container(
              height: exercise.hasLink? 70 : 75,
              decoration: BoxDecoration(
                borderRadius: getBorderRadius(
                    hasLink: exercise.hasLink,
                    isTotalLastItem: isTotalLastItem,
                    isLastItemInGroup: isLastItemInGroup
                ),
                color: CupertinoTheme.of(context).barBackgroundColor,
              ),
              margin: EdgeInsets.only(bottom: withSpacer? heightSpacerExerciseRow : 0),
              child: exerciseRow
          )
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exercise.hasLink)
          SpaceFixerHorizontalLine(
            context: context,
            overflowHeight: 2,
            width: MediaQuery.of(context).size.width - 40,
            overflowColor: CupertinoTheme.of(context).barBackgroundColor,
          ),
        Slidable(
            key: exercise.key,
            controller: exercise.slidableController,
            closeOnScroll: false,
            groupTag: 1,
            endActionPane: buildEndActionPane(onDismissed: onDismissed),
            startActionPane: buildExerciseStartActionPane(
                exercise: exercise.exercise!,
                onTapCopy: onTapCopy,
                onTapChangeLinkState: onTapChangeLinkState
            ),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: exercise.hasLink? 70 : 75,
                decoration: BoxDecoration(
                  borderRadius: getBorderRadius(
                      hasLink: exercise.hasLink,
                      isTotalLastItem: isTotalLastItem,
                      isLastItemInGroup: isLastItemInGroup
                  ),
                  color: CupertinoTheme.of(context).barBackgroundColor,
                ),
                child: exerciseRow
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? heightSpacerExerciseRow : 0,
        )
      ],
    );
  }

  BorderRadius getBorderRadius({
    required bool hasLink,
    required bool isTotalLastItem,
    required bool isLastItemInGroup
  }){
    if (hasLink){
      if(isTotalLastItem || isLastItemInGroup){
        return const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8));
      }
      return BorderRadius.zero;
    }
    else {
      return BorderRadius.circular(8);
    }
  }
}