import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_per_link.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../util/constants.dart';
import '../../../screen_running_workout.dart';
import '../../../selector_exercises_to_update.dart';
import 'open_pop_up_confirm_cancel_workout.dart';

Future openPopUpFinishWorkout(
    BuildContext context,
    CnRunningWorkout cnRunningWorkout,
    CnSelectorExerciseToUpdate cnSelectorExerciseToUpdate,
    // CnSelectorExercisePerLink cnSelectorExercisePerLink
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

                // cnRunningWorkout.checkMultipleExercisesPerLink();
                /// Open Exercise per link selector
                // if(cnRunningWorkout.linkWithMultipleExercisesStarted.isNotEmpty){
                //   cnSelectorExerciseToUpdate.setDescendantName("SelectorExercisePerLink");
                //   Future.delayed(const Duration(milliseconds: 100), () async{
                //     FocusManager.instance.primaryFocus?.unfocus();
                //     cnSelectorExercisePerLink.initData(
                //         groupedExercises: cnRunningWorkout.groupedExercises,
                //         relevantLinkNames: cnRunningWorkout.linkWithMultipleExercisesStarted
                //     );
                //     Future.delayed(const Duration(milliseconds: (50)), () async{
                //       await cnSelectorExercisePerLink.openPanel();
                //     });
                //   });
                // }

                /// Open Exercise to update selector or finish workout if no update is needed
                // else{
                  cnSelectorExerciseToUpdate.setDescendantName("ScreenRunningWorkout");
                  if(context.mounted){
                    cnRunningWorkout.confirmSelectorExPerLink(delay: 0, context: context);
                  // }
                }
              });
            },
            child: Text(AppLocalizations.of(context)!.finish, style: cupButtonTextStyle),
          ),
      ],
    ),
  );
}