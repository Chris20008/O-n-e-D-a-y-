import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../objects/exercise.dart';
import '../objects/workout.dart';
import '../screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/screen_workouts/screen_running_workout.dart';
import 'bottom_menu.dart';
import 'multiple_exercise_row.dart';

class WorkoutExpansionTile extends StatefulWidget {
  final Function? onExpansionChange;
  final EdgeInsets padding;
  final bool initiallyExpanded;
  final Workout workout;

  const WorkoutExpansionTile({
    super.key,
    this.onExpansionChange,
    this.initiallyExpanded = false,
    this.padding = const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
    required this.workout
  });

  @override
  State<WorkoutExpansionTile> createState() => _WorkoutExpansionTileState();
}

class _WorkoutExpansionTileState extends State<WorkoutExpansionTile> {
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
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
                  setState(() {
                    if(widget.onExpansionChange != null){
                      widget.onExpansionChange!(isOpen);
                    }
                    isOpened = isOpen;
                  });
                },
                initiallyExpanded: widget.initiallyExpanded,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!widget.workout.isTemplate)
                      Text(
                        DateFormat('E. d. MMMM').format(widget.workout.date!),
                        textScaleFactor: 0.8,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w100
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: ExerciseNameText(
                                widget.workout.name,
                                maxLines: 1,
                                fontsize: 26,
                                minFontSize: 20
                            )
                        ),
                        if(widget.workout.isTemplate)
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
                        firstChild: Row(
                          children: [
                            const Spacer(flex: 1,),
                            Expanded(
                              flex: 3,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                runAlignment: WrapAlignment.end,
                                children: [
                                  for (Exercise ex in widget.workout.exercises)
                                    if(ex == widget.workout.exercises.last)
                                      Text(ex.name, style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300))
                                    else
                                      Text("${ex.name}, ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300))
                                ],
                              ),
                            ),
                          ],
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
