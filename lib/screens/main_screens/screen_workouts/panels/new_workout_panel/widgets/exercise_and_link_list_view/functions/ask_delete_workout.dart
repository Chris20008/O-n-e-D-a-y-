import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'delete_workout.dart';

Future askDeleteWorkout(BuildContext context) async {
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      cancelButton: getActionSheetCancelButton(context),
      message: Text(AppLocalizations.of(context)!.panelWoDeleteWorkout),
      actions: <Widget>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () async {
            await deleteWorkout(context: context);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.delete, style: cupButtonTextStyleOnlyFontSize),
        ),
      ],
    ),
  );
}