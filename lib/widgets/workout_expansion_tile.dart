import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../objects/exercise.dart';
import '../objects/workout.dart';
import '../screens/other_screens/screen_running_workout/screen_running_workout.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/main_screens/screen_workouts/screen_workouts.dart';
import 'bottom_menu.dart';
import 'multiple_exercise_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late bool isOpened = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          // color: const Color(0x33939393),
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
                        DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(widget.workout.date!),
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
                              onPressed: () {
                                if(!cnRunningWorkout.isRunning){
                                  cnRunningWorkout.isRunning = true;
                                  cnRunningWorkout.workout = Workout.copy(widget.workout);
                                  cnWorkouts.refresh();
                                  HapticFeedback.selectionClick();
                                  Future.delayed(const Duration(milliseconds: 300), (){
                                    cnRunningWorkout.openRunningWorkout(context, Workout.copy(widget.workout));
                                  });
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
                              cnNewWorkout.editWorkout(workout: widget.workout);
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
                                          style: TextStyle(color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.6), fontWeight: FontWeight.w400)
                                          // style: TextStyle(color: CupertinoColors.inactiveGray.withOpacity(0.7), fontWeight: FontWeight.w400)
                                      )
                                    else
                                      OverflowSafeText(
                                          "${ex.name}, ",
                                          maxLines: 1,
                                          fontSize: 15,
                                          minFontSize: 15,
                                          style: TextStyle(color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.6), fontWeight: FontWeight.w400)
                                      )
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
                  MultipleExerciseRow(
                    exercises: widget.workout.exercises,
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }

  void openPopUp(String nameNewWorkout){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context),
        title: Text(AppLocalizations.of(context)!.woAlreadyRunning(cnRunningWorkout.workout.name)),
        message: Text(AppLocalizations.of(context)!.woAlreadyRunningDelete(nameNewWorkout)),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Future.delayed(Duration(milliseconds: 200), (){
                cnRunningWorkout.openRunningWorkout(context, Workout.copy(widget.workout));
              });

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  }
}
