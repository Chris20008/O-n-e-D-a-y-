import 'package:collection/collection.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'change_block_link_state.dart';
import 'move_tile.dart';

const int delayChangeBlockLinkState = 200;

Future tapChangeLinkState({
  required int index,
  required Exercise exercise,
  required bool isTotalLastItem,
  required bool isLastItemInGroup,
  required CnNewWorkOutPanel cnNewWorkout
}) async{

  /// Exercise with currently link not blocked
  /// Either above all groups, so has no link or currently part of a group
  if(!exercise.blockLink){

    /// Either has no link name          ->  no animated moving necessary
    /// or is absolut last item          ->  no animated moving necessary
    /// or is last item in link group    ->  no animated moving necessary
    if(exercise.linkName == null                                /// has no linkname
        || isTotalLastItem                                      /// is last item
        || isLastItemInGroup                                    /// is last item in link group
    ){
      await changeBlockLinkState(exercise, cnNewWorkout, delay: delayChangeBlockLinkState);
      return;
    }

    /// Otherwise we have to calculate the new position and move the Exercise tile
    /// to it's new position animated
    /// This new position is the last position of it's current link group

    final newIndex = cnNewWorkout.exercisesAndLinks.lastIndexWhere((element) => element.linkName == cnNewWorkout.exercisesAndLinks[index].linkName);
    /// return if no new Index was found
    if(newIndex == -1){
      return;
    }

    /// calculate the distance in pixels by iterating over every item in exercisesAndLinks
    /// and calculate it's size from current to new index position
    double distance = 0;
    for(int i = index; i < newIndex; i++){
      distance += getWidgetSize(cnNewWorkout.exercisesAndLinks[index].key).height;
    }

    /// move the tile from old to new position by starting at the lastPointerPosition
    /// to the lastPointerPosition + the calculated distance
    await moveTile(startY: cnNewWorkout.lastPointerPosition.dy, endY: cnNewWorkout.lastPointerPosition.dy + distance, cnNewWorkout: cnNewWorkout);

    /// After that change the block link state
    /// If the blocking was deactivated
    await changeBlockLinkState(exercise, cnNewWorkout);
  }

  else{
    final element = cnNewWorkout.exercisesAndLinks.lastWhereIndexedOrNull((previousIndex, element) => previousIndex < index && element.linkName != null);

    if(element == null){
      await changeBlockLinkState(exercise, cnNewWorkout, delay: delayChangeBlockLinkState);
      return;
    }

    final newIndex = cnNewWorkout.exercisesAndLinks.indexOf(element);
    if(index - newIndex == 1){
      await changeBlockLinkState(exercise, cnNewWorkout, delay: delayChangeBlockLinkState);
      return;
    }
    else{
      final Offset widgetPosition = getWidgetPosition(cnNewWorkout.exercisesAndLinks[index].key);

      double distance = 0;
      for(int i = newIndex+1; i < index; i++){
        final element = cnNewWorkout.exercisesAndLinks[index];
        distance += getWidgetSize(element.key).height;
        if(element.isExercise && element.exercise!.blockLink){
          distance += cnNewWorkout.heightSpacerExerciseRow;
        }
      }
      await moveTile(startY: widgetPosition.dy, endY: widgetPosition.dy - distance, cnNewWorkout: cnNewWorkout);

      await changeBlockLinkState(exercise, cnNewWorkout);
    }
  }
}