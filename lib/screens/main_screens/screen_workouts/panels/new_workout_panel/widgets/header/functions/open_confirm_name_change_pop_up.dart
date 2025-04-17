import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void openConfirmNameChangePopUp(BuildContext context){

  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);

  cnStandardPopUp.open(
    context: context,
    confirmText: AppLocalizations.of(context)!.yes,
    cancelText: AppLocalizations.of(context)!.no,
    maxWidth: MediaQuery.of(context).size.width,
    widthFactor: 0.9,
    padding: const EdgeInsets.all(15),
    child: Column(
      children: [
        Text(
          AppLocalizations.of(context)!.panelWoWorkoutNameChanged,
          textScaler: const TextScaler.linear(1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          AppLocalizations.of(context)!.panelWoWorkoutNameChangedMessage,
          textScaler: const TextScaler.linear(1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(
              maxHeight: 400
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [

                /// new workout name
                if(cnNewWorkout.originalWorkout.name != cnNewWorkout.workout.name)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        const SizedBox(height: 20,),
                        Text(AppLocalizations.of(context)!.panelWoWorkoutName, textScaler: const TextScaler.linear(1.2),),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(cnNewWorkout.originalWorkout.name, maxLines: 3, fontSize: 15, minFontSize: 10))),
                            const Expanded(child: Center(child: Icon(Icons.arrow_right_alt))),
                            Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(cnNewWorkout.workout.name, maxLines: 3, fontSize: 15, minFontSize: 10))),
                            // const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),

                /// New exercises names
                if(cnNewWorkout.exerciseNewNameMapping.isNotEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 20),
                        child: Text(AppLocalizations.of(context)!.panelWoExerciseNames, textScaler: const TextScaler.linear(1.2),),
                      ),
                      for(MapEntry entry in cnNewWorkout.exerciseNewNameMapping.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(entry.key, maxLines: 3, fontSize: 15, minFontSize: 10))),
                              const Expanded(child: Center(child: Icon(Icons.arrow_right_alt))),
                              Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(entry.value, maxLines: 3, fontSize: 15, minFontSize: 10)))
                            ],
                          ),
                        )
                    ],
                  ),
              ],
            ),
          ),
        )
      ],
    ),
    onConfirm: () async{
      cnNewWorkout.applyNameChanges = true;
      await cnNewWorkout.onConfirm(context);
    },
    onCancel: () async{
      cnNewWorkout.applyNameChanges = false;
      await cnNewWorkout.onConfirm(context);
    },
    onTapOutside: (){
      cnNewWorkout.applyNameChanges = false;
    },
  );
}