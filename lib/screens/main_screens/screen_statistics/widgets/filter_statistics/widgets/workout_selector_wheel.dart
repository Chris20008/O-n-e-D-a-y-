import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/vertical_scroll_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';


class WorkoutSelectorWheel extends StatelessWidget {
  const WorkoutSelectorWheel({super.key});

  @override
  Widget build(BuildContext context) {
    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();

    List<String> workoutNames = List.from(cnScreenStatistics.allWorkoutNames);
    /// Replace the "ALL Workouts" name in correct language
    workoutNames[0] = AppLocalizations.of(context)!.filterAllWorkouts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
          height:50,
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                size: 15,
              ),
              Expanded(
                child: VerticalScrollWheel(
                  widthOfChildren: 100,
                  heightOfChildren: 30,
                  onTap: (int index){
                    cnScreenStatistics.selectedWorkoutName = cnScreenStatistics.allWorkoutNames[index];
                    cnScreenStatistics.selectedWorkoutIndex = index;
                    HapticFeedback.selectionClick();
                  },
                  selectedIndex: cnScreenStatistics.selectedWorkoutIndex,
                  children: List<Widget>.generate(
                      workoutNames.length, (index) =>
                      OverflowSafeText(
                          workoutNames[index],
                          maxLines: 1
                      )
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          )
      ),
    );
  }
}
