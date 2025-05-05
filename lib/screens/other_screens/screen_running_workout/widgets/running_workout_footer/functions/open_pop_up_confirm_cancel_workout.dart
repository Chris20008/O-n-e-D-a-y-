import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../util/constants.dart';
import '../../../screen_running_workout.dart';

Future openPopUpConfirmCancelWorkout(BuildContext context, CnRunningWorkout cnRunningWorkout) async{
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      cancelButton: getActionSheetCancelButton(context, text: AppLocalizations.of(context)!.runningWorkoutContinueWorkout),
      title: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
      message: Text(AppLocalizations.of(context)!.runningWorkoutConfirmCancelWorkout),
      actions: <Widget>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            cnRunningWorkout.stopWorkout(context: context);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout, style: cupButtonTextStyleOnlyFontSize),
        ),
      ],
    ),
  );
}