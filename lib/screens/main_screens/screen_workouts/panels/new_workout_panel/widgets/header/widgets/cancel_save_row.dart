import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/widgets/workout_or_sick_days_picker.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../functions/open_confirm_name_change_pop_up.dart';

class CancelSaveRow extends StatefulWidget {
  const CancelSaveRow({super.key});

  @override
  State<CancelSaveRow> createState() => _CancelSaveRowState();
}

class _CancelSaveRowState extends State<CancelSaveRow> {

  late CnNewWorkOutPanel cnNewWorkout;

  @override
  Widget build(BuildContext context) {

    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

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
                      onPressed: () async => await cnNewWorkout.onCancel(context),
                      text: AppLocalizations.of(context)!.cancel,
                      textAlign: TextAlign.left
                  )
              )
          ),
          Expanded(
            flex: 11,
            child: Align(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: cnNewWorkout.workout.isTemplate && cnNewWorkout.workout.isEmpty() && MediaQuery.of(context).viewInsets.bottom == 0
                    ?const WorkoutOrSickDaysPicker()
                    :Text(
                  cnNewWorkout.workout.isTemplate
                      ? AppLocalizations.of(context)!.panelWoWorkoutTemplate
                      : cnNewWorkout.isSickDays
                      ? AppLocalizations.of(context)!.statisticsSick
                      : " ", /// Due to Fitted Box the length must be greater than 0
                  textScaler: const TextScaler.linear(1.3),
                  // style: TextStyle(color: Colors.grey)
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.centerRight,
              child: CupertinoButtonText(
                  onPressed: () async{
                    if(!cnNewWorkout.hasChangedNames()){
                      await cnNewWorkout.onConfirm(context);
                    }
                    else{
                      openConfirmNameChangePopUp(context);
                    }
                  },
                  text: AppLocalizations.of(context)!.save,
                  textAlign: TextAlign.right
              ),
            ),
          ),
        ],
      ),
    );
  }
}
