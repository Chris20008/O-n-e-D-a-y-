import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkoutOrSickDaysPicker extends StatelessWidget {
  const WorkoutOrSickDaysPicker({super.key});

  @override
  Widget build(BuildContext context) {

    CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
    CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

    return SizedBox(
      height: 30,
      child: PullDownButton(
        onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
        routeTheme: routeTheme,
        itemBuilder: (context) {
          return [
            PullDownMenuItem.selectable(
              title: "Workout",
              selected: !cnNewWorkout.isSickDays,
              onTap: () {
                cnNewWorkout.isSickDays = false;
                cnNewWorkout.minPanelHeight = cnNewWorkout.keepShowingPanelHeight;
                cnNewWorkout.refresh();
                cnWorkouts.refresh();
                cnHomepage.refresh();
              },
            ),
            PullDownMenuItem.selectable(
              title: AppLocalizations.of(context)!.statisticsSick,
              selected: cnNewWorkout.isSickDays,
              onTap: () {
                cnNewWorkout.isSickDays = true;
                cnNewWorkout.minPanelHeight = cnNewWorkout.keepShowingPanelHeightSickDays;
                cnNewWorkout.refresh();
                cnWorkouts.refresh();
                cnHomepage.refresh();
              },
            ),
          ];
        },
        buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cnNewWorkout.isSickDays
                    ?AppLocalizations.of(context)!.statisticsSick
                    :cnNewWorkout.workout.isTemplate
                    ? AppLocalizations.of(context)!.panelWoWorkoutTemplate
                    : "",//AppLocalizations.of(context)!.panelWoWorkoutFinished,
                style: const TextStyle(color: Colors.white),
                textScaler: const TextScaler.linear(1.1),
              ),
              const SizedBox(width: 10),
              trailingChoice()
            ],
          ),
        ),
      ),
    );
  }
}
