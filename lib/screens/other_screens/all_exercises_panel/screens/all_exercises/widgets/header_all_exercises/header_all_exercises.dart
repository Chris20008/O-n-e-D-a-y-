import 'dart:ui';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/all_exercises_panel.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/header_all_exercises/widgets/top_header_letter.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:fitness_app/widgets/panel_header_row.dart';
import 'package:fitness_app/widgets/scroll_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../objects/exercise.dart';

class HeaderAllExercises extends StatelessWidget {

  const HeaderAllExercises({super.key});

  @override
  Widget build(BuildContext context) {
    CnNewExercisePanel cnNewExercisePanel = context.read<CnNewExercisePanel>();
    CnNewWorkOutPanel cnNewWorkOutPanel = context.read<CnNewWorkOutPanel>();
    CnAllExercisesPanel cnAllExercisesPanel = context.read<CnAllExercisesPanel>();

    return ClipRRect(
      child: ScrollListener(
        controller: cnAllExercisesPanel.scrollController,
        minValue: 0,
        maxValue: 1,
        maxOffset: 15,
        inverted: true,
        builder: (context, value, _) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 30 * value,
                sigmaY: 30 * value,
                tileMode: TileMode.mirror
            ),
            child: Container(
              // color: Colors.transparent,
              color: Theme.of(context).primaryColor.withValues(alpha: 1-value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PanelHeaderRow(
                      flexLeft: 15,
                      flexRight: 15,
                      childLeft: CupertinoButtonText(
                          text: AppLocalizations.of(context)!.cancel,
                          onPressed: () => cnAllExercisesPanel.closePanel()
                      ),
                      childMiddle: const Text(
                        "Übungen",
                        style: const TextStyle(fontSize: 17),
                      ),
                      childRight: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  "Neue Übung",
                                style: TextStyle(
                                    color: Colors.amber[800]?? const Color(0xFFFF9A19)
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.amber[800]?? const Color(0xFFFF9A19),
                              ),
                            ],
                          ),
                          onPressed: (){
                            cnNewExercisePanel.clear(withRefresh: false);
                            cnNewExercisePanel.onConfirm = (Exercise exercise){
                              cnNewWorkOutPanel.confirmAddExercise(exercise);
                              cnAllExercisesPanel.closePanel();
                            };
                            cnAllExercisesPanel.navigatorKey?.currentState?.pushNamed('/singleExercise')
                                .then(cnAllExercisesPanel.callBackRefreshAllExercisesList());
                          }
                      )
                  ),
                  Container(
                    height: 0.1,
                    color: CupertinoColors.systemGrey,
                  ),
                  const TopHeaderLetter()
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
