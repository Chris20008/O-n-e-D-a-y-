import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../objects/exercise.dart';
import '../objects/workout.dart';
import '../screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/screen_workouts/screen_running_workout.dart';
import 'multiple_exercise_row.dart';

class WorkoutExpansionTile extends StatefulWidget {
  // final Function onEdit;
  final bool showStartWorkout;
  final Function? onExpansionChange;
  final EdgeInsets padding;
  final bool initiallyExpanded;
  final Workout workout;

  const WorkoutExpansionTile({
    super.key,
    this.showStartWorkout = false,
    this.onExpansionChange,
    this.initiallyExpanded = false,
    this.padding = const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
    // required this.onEdit,
    required this.workout
  });

  @override
  State<WorkoutExpansionTile> createState() => _WorkoutExpansionTileState();
}

class _WorkoutExpansionTileState extends State<WorkoutExpansionTile> {
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late bool isOpened = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
                tilePadding: const EdgeInsets.only(left: 10, right: 20),
                onExpansionChanged: (bool isOpen) {
                  if(widget.onExpansionChange != null){
                    widget.onExpansionChange!(isOpen);
                  }
                  isOpened = isOpen;
                },
                initiallyExpanded: widget.initiallyExpanded,
                title: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.workout.name,
                          textScaleFactor: 1.7,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Expanded(child: SizedBox()),
                        if(widget.showStartWorkout)
                          IconButton(
                              onPressed: () {
                                cnRunningWorkout.openRunningWorkout(context, Workout.copy(widget.workout));
                              },
                              icon: Icon(Icons.play_arrow,
                                color: Colors.grey.withOpacity(0.4),
                              )
                          ),
                        IconButton(
                            onPressed: () {
                              cnNewWorkout.editWorkout(widget.workout);
                            },
                            icon: Icon(Icons.edit,
                              color: Colors.grey.withOpacity(0.4),
                            )
                        )
                      ],
                    ),
                    AnimatedCrossFade(
                        firstChild: SizedBox(
                          width: double.maxFinite,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.start,
                            children: [
                              for (Exercise ex in widget.workout.exercises)
                                if(ex == widget.workout.exercises.last)
                                  Text(ex.name, style: const TextStyle(color: Colors.white))
                                else
                                  Text("${ex.name}, ", style: const TextStyle(color: Colors.white))
                            ],
                          ),
                        ),
                        secondChild: const SizedBox(width: double.maxFinite),
                        crossFadeState: !isOpened?
                        CrossFadeState.showFirst:
                        CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200)
                    )
                  ],
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LimitedBox(
                          maxHeight: 1000,
                          child: MultipleExerciseRow(
                            exercises: widget.workout.exercises,
                            textScaleFactor: 1.3,
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          )
                      )
                    ],
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}
