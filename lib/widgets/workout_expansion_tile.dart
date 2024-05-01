import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../objects/exercise.dart';
import '../objects/workout.dart';
import '../screens/screen_running_workout/screen_running_workout.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/main_screens/screen_workouts/screen_workouts.dart';
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
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late bool isOpened = widget.initiallyExpanded;
  final startWorkoutKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.black.withOpacity(0.5),
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
                        textScaler: const TextScaler.linear(0.8),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: OverflowSafeText(
                                widget.workout.name,
                                maxLines: 1,
                                fontSize: 26,
                                minFontSize: 20
                            )
                        ),
                        if(widget.workout.isTemplate)
                          IconButton(
                              key: startWorkoutKey,
                              onPressed: () {
                                if(!cnRunningWorkout.isRunning){
                                  cnRunningWorkout.openRunningWorkout(context, Workout.copy(widget.workout));
                                }
                                else{
                                  if(cnRunningWorkout.workout.name == widget.workout.name){
                                    cnRunningWorkout.reopenRunningWorkout(context);
                                  }
                                  else{
                                    openPopUp(widget.workout.name);
                                  }
                                }
                              },
                              icon: Icon(Icons.play_arrow,
                                color: !cnRunningWorkout.isRunning
                                    ? Colors.grey.withOpacity(0.4)
                                    : cnRunningWorkout.workout.name == widget.workout.name
                                      ? (Colors.amber[800]?? Colors.orange).withOpacity(0.8)
                                      : Colors.grey.withOpacity(0.2)
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
                              flex: 5,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                runAlignment: WrapAlignment.end,
                                children: [
                                  for (Exercise ex in widget.workout.exercises)
                                    if(ex == widget.workout.exercises.last)
                                      OverflowSafeText(
                                          ex.name,
                                          maxLines: 1,
                                          fontSize: 15,
                                          minFontSize: 15,
                                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300)
                                      )
                                      // Text(ex.name, style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300))
                                    else
                                      OverflowSafeText(
                                          "${ex.name}, ",
                                          maxLines: 1,
                                          fontSize: 15,
                                          minFontSize: 15,
                                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300)
                                      )
                                      // Text("${ex.name}, ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w300))
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
                            // textScaleFactor: 1.3,
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

  void openPopUp(String nameNewWorkout){
    cnStandardPopUp.open(
      context: context,
      color: const Color(0xff2d2d2d),
      animationKey: startWorkoutKey,
      confirmText: "Yes",
      cancelText: "No",
      onConfirm: () {
        Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
          cnRunningWorkout.openRunningWorkout(context, Workout.copy(widget.workout));
        });
      },
      padding: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            OverflowSafeText(
              "Workout ${cnRunningWorkout.workout.name} is already Running",
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 10,),
            OverflowSafeText(
              "Do you want to stop the current workout and start workout $nameNewWorkout?",
              maxLines: 6,
              textAlign: TextAlign.center,
              fontSize: 14
              // fontSize:
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
