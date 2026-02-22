import 'package:flutter/cupertino.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import '../../../../../../util/constants.dart';
import '../../../screen_running_workout.dart';
import '../../selector_exercises_to_update.dart';
import 'open_pop_up_confirm_cancel_workout.dart';

Future openPopUpFinishWorkout(
    BuildContext context,
    CnRunningWorkout cnRunningWorkout,
    CnSelectorExerciseToUpdate cnSelectorExerciseToUpdate,
    ) async{

  final bool canFinish = cnRunningWorkout.hasStartedWorkout();

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext childContext) => CupertinoActionSheet(
      cancelButton: getActionSheetCancelButton(context, text: AppLocalizations.of(context)!.runningWorkoutContinueWorkout),
      title: Text(AppLocalizations.of(context)!.runningWorkoutFinishWorkout),
      actions: <Widget>[

        /// Workout Cancel Button
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(childContext);
            Future.delayed(const Duration(milliseconds: 250), (){
              if(context.mounted){
                openPopUpConfirmCancelWorkout(context, cnRunningWorkout);
              }
            });
          },
          child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout, style: cupButtonTextStyleOnlyFontSize),
        ),

        /// Workout Finish Button
        if(canFinish)
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(childContext);
              Future.delayed(const Duration(milliseconds: 200), (){

                /// Open Exercise to update selector or finish workout if no update is needed
                if(context.mounted){
                  cnRunningWorkout.updateOrFinishWorkout(delay: 0, context: context);
                }
              });
            },
            child: Text(AppLocalizations.of(context)!.finish, style: cupButtonTextStyle),
          ),
      ],
    ),
  );
}