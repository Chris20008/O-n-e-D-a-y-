import 'dart:io';
import 'dart:ui';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/bottom_spacer.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/exercise_header/exercise_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../../../../objects/exercise.dart';
import '../../../../../util/constants.dart';
import '../../screen_running_workout.dart';
import '../../setRow.dart';

class RunningWorkoutContent extends StatefulWidget {
  const RunningWorkoutContent({super.key});

  @override
  State<RunningWorkoutContent> createState() => _RunningWorkoutContentState();
}

class _RunningWorkoutContentState extends State<RunningWorkoutContent> {

  String? currentDraggingKey;
  late CnRunningWorkout cnRunningWorkout;// = Provider.of<CnRunningWorkout>(context, listen: false);
  final double iconSize = 20;
  final style = const TextStyle(color: Colors.white, fontSize: 15);

  @override
  Widget build(BuildContext context) {

    print("Running Workout Content");

    final contentIsActive = context.select<CnRunningWorkout, bool>((cn) => cn.contentIsActive);
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: true);

    if(contentIsActive) {
      return SlidableAutoCloseBehavior(
        child: ReorderableListView.builder(
          scrollController: cnRunningWorkout.scrollController,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          onReorderStart: (index) {
            currentDraggingKey = cnRunningWorkout.groupedExercises.entries.toList()[index].key.split("_").firstOrNull;
          },
          onReorderEnd: (index) {
            currentDraggingKey = null;
          },
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            dynamic movingItem = cnRunningWorkout.groupedExercises[cnRunningWorkout.groupedExercises.keys.toList()[oldIndex]];
            dynamic newIndexItem = cnRunningWorkout.groupedExercises[cnRunningWorkout.groupedExercises.keys.toList()[newIndex]];

            if (movingItem is GroupedSet && newIndexItem is GroupedSet) {
              String linkNameOld = cnRunningWorkout.groupedExercises.keys.toList()[oldIndex].split("_").first;
              String linkNameNew = cnRunningWorkout.groupedExercises.keys.toList()[newIndex].split("_").first;
              if (linkNameOld != linkNameNew) {
                return;
              }
              Exercise exOld = (cnRunningWorkout.groupedExercises[linkNameOld] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkNameOld]!)!;
              Exercise exNew = (cnRunningWorkout.groupedExercises[linkNameNew] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkNameNew]!)!;
              movingItem = movingItem.getSet(exOld.name);
              newIndexItem = newIndexItem.getSet(exNew.name);
            }

            if (movingItem is NamedSet && newIndexItem is NamedSet &&
                movingItem.name == newIndexItem.name) {
              NamedSet? setToMove = cnRunningWorkout.removeSpecificSetFromExercise(movingItem);

              if (setToMove == null) {
                return;
              }
              setToMove.index = newIndexItem.index;

              if (oldIndex < newIndex) {
                setToMove.index += 1;
              }
              cnRunningWorkout.addSpecificSetToExercise(setToMove);
              cnRunningWorkout.refresh();
              // setState(() {});
            }
          },
          proxyDecorator: (Widget child, int index,
              Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue = Curves.easeInOut.transform(
                    animation.value);
                final double scale = lerpDouble(1, 1.06, animValue)!;
                return Transform.scale(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                        child: Container(
                            padding: const EdgeInsets.only(left: 2),
                            color: Colors.grey.withValues(alpha: 0.1),
                            child: child
                        )
                    ),
                  ),
                );
              },
              child: child,
            );
          },
          itemCount: cnRunningWorkout.groupedExercises.length,
          itemBuilder: (BuildContext context, int indexExercise) {
            dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
            return getItem(indexExercise);
          },
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
        itemCount: cnRunningWorkout.groupedExercises.length,
        controller: cnRunningWorkout.scrollController,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index){
          return getItem(index);
        }
    );
  }

  Widget getItem(int indexExercise) {
    Widget? child;

    /// gets the map key from the indexed value
    /// is either the linkname, when grouped set - related sets like linkname_A, linkname_B for each set
    /// the exercisename - related sets like exercisename_A, exercisename_B for each set
    /// or the separator exercisename_| Separator or linkname_|Separator depending on group or no group
    String groupedExerciseKey = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key;
    // dynamic mapValue = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
    dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;

    if(item.toString().contains("Separator")){
      dynamic previousItem = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise-1].value;
      late Exercise ex;
      if(previousItem is NamedSet){
        ex = previousItem.ex;
      }
      else{
        previousItem = previousItem as GroupedSet;
        String linkName = groupedExerciseKey.split("_").first;
        ex = (cnRunningWorkout.groupedExercises[linkName] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkName]!)!;
      }

      Exercise? templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((e) => e.name == ex.name).firstOrNull;

      child = GestureDetector(
        /// Empty long press to prevent dragging
        onLongPress: (){},
        child: Column(
          children: [
            const SizedBox(height: 10,),
            getRowButton(
                context: context,
                minusWidth: 10,
                height: 35,
                onPressed: (){
                  cnRunningWorkout.addSet(ex: ex, lastEx: templateEx!);
                }
            ),
            if(indexExercise < cnRunningWorkout.groupedExercises.length-1)
              mySeparator(),
          ],
        ),
      );
    }

    else if(item is Exercise || item is GroupedExercise){

      Exercise? exercise = item is Exercise ? item : (item as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!);
      GroupedExercise? exerciseGroup = item is GroupedExercise ? item : null;

      if(exercise == null){
        return const SizedBox();
      }

      child = ExerciseHeader(
          exercise: exercise,
          exerciseGroup: exerciseGroup,
          currentSelectedExerciseName: exerciseGroup?.getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!)?.name,
          onChangeSelectedExercise: (tappedName){
            FocusManager.instance.primaryFocus?.unfocus();
            HapticFeedback.selectionClick();
            Future.delayed(const Duration(milliseconds: 200), (){
              setState(() {
                final exercises = item.exercises;
                final t = exercises.indexWhere((ex) => ex.name == tappedName);

                cnRunningWorkout.selectedIndexes[groupedExerciseKey] = t;
              });
              cnRunningWorkout.cache();
            });
          }
      );
    }

    /// Single Set Row
    if(item is NamedSet || item is GroupedSet){
      child = SetRow(
          cnRunningWorkout: cnRunningWorkout,
          item: item,
          groupedExerciseKey: groupedExerciseKey,
          index: indexExercise
      );
    }

    /// Top Spacer
    if (indexExercise == 0){
      child = Column(
        children: [
          SizedBox(height: Platform.isAndroid? 80 : 120),
          child?? const SizedBox()
        ],
      );
    }

    /// Bottom Spacer
    if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
      child = Column(
        children: [
          child?? const SizedBox(),
          const BottomSpacerRunningWorkout(),
        ],
      );
    }

    return Container(
        key: currentDraggingKey == null ||
            ((item is NamedSet || item is GroupedSet)
                && groupedExerciseKey.contains(currentDraggingKey!))
            ? ValueKey(groupedExerciseKey)
            : UniqueKey(),
        // key: key,
        // key: ValueKey(groupedExerciseKey),
        child: child?? const SizedBox());
  }
}
