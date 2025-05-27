import 'package:fitness_app/screens/other_screens/all_exercises_panel/all_exercises_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ChildLeftHeaderRow extends StatelessWidget {
  const ChildLeftHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cn = context.read<CnAllExercisesPanel>();

    return CupertinoButton(
      onPressed: () => cn.getNavigatorKey(context)?.currentState?.pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.amber[800]?? const Color(0xFFFF9A19),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.welcomeBack,
            style: TextStyle(
                color: Colors.amber[800]?? const Color(0xFFFF9A19)
            ),
          )
        ],
      ),
    );
  }
}
