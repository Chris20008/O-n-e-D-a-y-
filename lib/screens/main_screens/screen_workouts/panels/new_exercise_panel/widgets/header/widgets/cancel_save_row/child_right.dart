import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../../../widgets/cupertino_button_text.dart';
import '../../../../new_exercise_panel.dart';

class ChildRight extends StatelessWidget {
  const ChildRight({super.key});

  @override
  Widget build(BuildContext context) {
    CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);

    return CupertinoButtonText(
        key: cnNewExercise.getKeySaveButton(context),
        onPressed: () => cnNewExercise.closePanelAndSaveExercise(context),
        text: AppLocalizations.of(context)!.save,
        textAlign: TextAlign.right
    );
  }
}
