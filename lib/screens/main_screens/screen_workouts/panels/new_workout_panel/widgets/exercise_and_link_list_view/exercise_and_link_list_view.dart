import 'dart:ui';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/add_exercise_button.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'functions/ask_delete_workout.dart';
import 'functions/get_reorderable_exercises_and_links.dart';

class ExerciseAndLinkListView extends StatefulWidget {
  final PanelListViewBuilder listView;

  const ExerciseAndLinkListView({
    super.key,
    required this.listView
  });

  @override
  State<ExerciseAndLinkListView> createState() => _ExerciseAndLinkListViewState();
}

class _ExerciseAndLinkListViewState extends State<ExerciseAndLinkListView> {

  late CnNewWorkOutPanel cnNewWorkout;
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    final List<Widget> bottomButtons = [
      if(!cnNewWorkout.isSickDays)
        AddExerciseButton(
            tutorialIsRunning: tutorialIsRunning,
            currentTutorialStep: currentTutorialStep
        ),

      Padding(
        padding: EdgeInsets.only(
            top: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom : 80
        ),
        child: !cnNewWorkout.workout.isNewWorkout() || !cnNewWorkout.sickDays.isNewSickDays()? getRowButton(
            context: context,
            minusWidth: 0,
            onPressed: () async => await askDeleteWorkout(context),
            icon: Icons.delete,
            color: CupertinoColors.destructiveRed
        ) : const SizedBox(),
      ),
    ];

    if(!cnNewWorkout.panelHasFullyOpened){
      return widget.listView(
        controller: cnNewWorkout.scrollController,
        physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: cnNewWorkout.workout.isTemplate? 140 : 190),
        shrinkWrap: true,
        autoScroll: !cnNewWorkout.blockUi,
        children: [
          ...getReorderableExercisesAndLinks(
            cnNewWorkout: cnNewWorkout,
            cnNewExercisePanel: cnNewExercisePanel
          ),
          ...bottomButtons
        ]
      );
    }

    return SlidableAutoCloseBehavior(
      child: widget.listView(
        controller: cnNewWorkout.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: cnNewWorkout.workout.isTemplate? 140 : 190),
        shrinkWrap: true,
        autoScroll: !cnNewWorkout.blockUi,
        children: [
          // SizedBox(height: cnNewWorkout.workout.isTemplate? 140 : 190),
          /// Exercises and Links
          ReorderableListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final double animValue = Curves.easeInOut.transform(animation.value);
                  final double scale = lerpDouble(1, 1.06, animValue)!;
                  return Transform.scale(
                    scale: scale,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        child: Container(
                            padding: const EdgeInsets.only(left: 2),
                            color: Colors.grey.withOpacity(0.05),
                            child: child
                        ),
                      ),
                    ),
                  );
                },
                child: child,
              );
            },
            onReorder: (int oldIndex, int newIndex){
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = cnNewWorkout.exercisesAndLinks.removeAt(oldIndex);
                cnNewWorkout.exercisesAndLinks.insert(newIndex, item);
                cnNewWorkout.updateExercisesLinks();
              });
            },
            children: getReorderableExercisesAndLinks(
                cnNewWorkout: cnNewWorkout,
                cnNewExercisePanel: cnNewExercisePanel
            ),
          ),

          ...bottomButtons

        ],
      ),
    );
  }
}
