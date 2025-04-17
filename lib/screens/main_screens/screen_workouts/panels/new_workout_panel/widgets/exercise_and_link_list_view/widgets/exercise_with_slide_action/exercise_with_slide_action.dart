import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/functions/end_action_pane.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/widgets/exercise_row_with_link_icon.dart';
import 'package:fitness_app/widgets/spacer_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'functions/start_action_pane.dart';

class ExerciseWithSlideAction extends StatelessWidget {
  final int index;
  final CnNewWorkOutPanel cnNewWorkout;

  const ExerciseWithSlideAction({
    super.key,
    required this.index,
    required this.cnNewWorkout
  });

  @override
  Widget build(BuildContext context) {

    final bool hasLink = (cnNewWorkout.exercisesAndLinks[index].exercise as Exercise).linkName != null;
    Exercise? nextExercise =  cnNewWorkout.exercisesAndLinks.length > index+1
        && cnNewWorkout.exercisesAndLinks[index+1].isExercise
        ? cnNewWorkout.exercisesAndLinks[index+1].exercise!
        : null;
    bool withSpacer = nextExercise?.linkName != cnNewWorkout.exercisesAndLinks[index].linkName
        || (nextExercise?.blockLink?? false)
        || (nextExercise?.linkName == null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLink)
          SpaceFixerHorizontalLine(
            context: context,
            overflowHeight: 2,
            width: MediaQuery.of(context).size.width - 40,
            overflowColor: Theme.of(context).cardColor,
          ),
        Slidable(
            key: cnNewWorkout.exercisesAndLinks[index].key,
            controller: cnNewWorkout.exercisesAndLinks[index].slidableController,
            closeOnScroll: false,
            groupTag: 1,
            endActionPane: buildExerciseEndActionPane(index: index, cnNewWorkout: cnNewWorkout),
            startActionPane: buildExerciseStartActionPane(index: index, cnNewWorkout: cnNewWorkout),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: hasLink? 70 : 75,
                child: ClipRRect(
                  borderRadius: getBorderRadius(hasLink, nextExercise),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    child: CupertinoButton(
                      pressedOpacity: MediaQuery.of(context).viewInsets.bottom <= 0? 0.4 : 1,
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        if(MediaQuery.of(context).viewInsets.bottom <= 0){
                          cnNewWorkout.openExercise(cnNewWorkout.exercisesAndLinks[index].exercise!, context: context);
                        } else{
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: ExerciseRowWithLinkIcon(
                          exercise: cnNewWorkout.exercisesAndLinks[index].exercise!,
                          borderRadius: getBorderRadius(hasLink, nextExercise),
                          hasLink: hasLink,
                      ),
                    ),
                  ),
                )
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? cnNewWorkout.heightSpacerExerciseRow : 0,
        )
      ],
    );
  }

  BorderRadius getBorderRadius(bool hasLink, Exercise? nextExercise){
    if (hasLink){
      if(nextExercise?.linkName != cnNewWorkout.exercisesAndLinks[index].linkName || nextExercise == null){
        return const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8));
      }
      return BorderRadius.zero;
    }
    else {
      return BorderRadius.circular(8);
    }
  }
}