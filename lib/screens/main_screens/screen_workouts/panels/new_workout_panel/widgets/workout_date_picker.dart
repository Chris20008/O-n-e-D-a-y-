import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkoutDatePicker extends StatelessWidget {

  const WorkoutDatePicker({
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);

    return Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.panelWoDate, textScaler: const TextScaler.linear(1.3),),
            const Spacer(),
            if(cnNewWorkout.workout.date != null)
              buildCalendarDialogButton(
                  context: context,
                  dateValues: [cnNewWorkout.workout.date?? DateTime.now()],
                  cnNewWorkout: cnNewWorkout,
                  onConfirm: (List<DateTime?>? values){
                    cnNewWorkout.workout.date = values?[0]?? cnNewWorkout.workout.date;
                    cnNewWorkout.refresh();
                  }
              )
          ],
        ),
      );
  }
}