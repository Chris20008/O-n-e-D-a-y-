import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/workout_or_sick_days_picker.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CancelSaveRow extends StatelessWidget {
  const CancelSaveRow({super.key});

  @override
  Widget build(BuildContext context) {

    CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 10,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButtonText(
                      onPressed: () => cnNewExercise.onCancel(context),
                      text: AppLocalizations.of(context)!.cancel,
                      textAlign: TextAlign.left
                  )
              )
          ),
          Expanded(
              flex: 11,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.exercise,
                  textScaler: const TextScaler.linear(1.3),
                  textAlign: TextAlign.center,
                ),
              )
          ),
          Expanded(
              key: cnNewExercise.keySaveButton,
              flex: 10,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButtonText(
                      onPressed: () => cnNewExercise.closePanelAndSaveExercise(context),
                      text: AppLocalizations.of(context)!.save,
                      textAlign: TextAlign.right
                  )
              )
          ),
        ],
      ),
    );
  }
}
