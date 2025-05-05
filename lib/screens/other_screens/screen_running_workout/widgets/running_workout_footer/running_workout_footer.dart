import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import '../../screen_running_workout.dart';
import '../../selector_exercises_per_link.dart';
import '../../selector_exercises_to_update.dart';
import 'functions/open_pop_up_finish_workout.dart';

class RunningWorkoutFooter extends StatelessWidget {
  const RunningWorkoutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
    late CnSelectorExerciseToUpdate cnSelectorExerciseToUpdate = Provider.of<CnSelectorExerciseToUpdate>(context, listen: false);
    // late CnSelectorExercisePerLink cnSelectorExercisePerLink = Provider.of<CnSelectorExercisePerLink>(context, listen: false);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
            tileMode: TileMode.mirror
        ),
        child: Selector<CnBottomMenu, double>(
            selector: (_, cn) => cn.height,
            builder: (_, height, __){
              return Container(
                height: height,
                color: Colors.black.withValues(alpha: 0.5),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async => await openPopUpFinishWorkout(
                      context,
                      cnRunningWorkout,
                      cnSelectorExerciseToUpdate,
                      // cnSelectorExercisePerLink
                  ),
                  child: Center(
                      child: Text(
                          AppLocalizations.of(context)!.finish,
                          style: TextStyle(
                              color: Colors.amber[800]
                          ),
                          textScaler: const TextScaler.linear(1.2)
                      )
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
