import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class LinkWithSlideAction extends StatefulWidget {
  final int index;

  const LinkWithSlideAction({
    super.key,
    required this.index
  });

  @override
  State<LinkWithSlideAction> createState() => _LinkWithSlideActionState();
}

class _LinkWithSlideActionState extends State<LinkWithSlideAction> {

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    bool withSpacer = cnNewWorkout.exercisesAndLinks.length-1 == widget.index
        || cnNewWorkout.exercisesAndLinks[widget.index+1].linkName != cnNewWorkout.exercisesAndLinks[widget.index].linkName;

    return Column(
      children: [
        Slidable(
            controller: cnNewWorkout.exercisesAndLinks[widget.index].slidableController,
            closeOnScroll: false,
            groupTag: 1,
            key: cnNewWorkout.exercisesAndLinks[widget.index].key,
            endActionPane: ActionPane(
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              dismissible: cnNewWorkout.blockUi? null : DismissiblePane(
                  onDismissed: () {cnNewWorkout.dismissLink(cnNewWorkout.exercisesAndLinks[widget.index]);
                  }),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context){
                    cnNewWorkout.dismissLink(cnNewWorkout.exercisesAndLinks[widget.index]);
                  },
                  backgroundColor: const Color(0xFFA12D2C),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: withSpacer? BorderRadius.circular(8) : const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
              ),
              child: Row(
                key: UniqueKey(),
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: OverflowSafeText(
                      cnNewWorkout.exercisesAndLinks[widget.index].linkName!,
                      textAlign: TextAlign.center,
                      // fontSize: 12,
                      // style: style,
                      minFontSize: 12,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? cnNewWorkout.heightSpacerExerciseRow : 0,
        )
      ],
    );
  }
}
