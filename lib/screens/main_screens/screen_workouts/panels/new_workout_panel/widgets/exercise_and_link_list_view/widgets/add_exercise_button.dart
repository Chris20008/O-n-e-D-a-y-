import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../objects/exercise.dart';
import '../../../../../../../other_screens/all_exercises_panel/all_exercises_panel.dart';
import '../../../../new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

class AddExerciseButton extends StatelessWidget {
  final bool tutorialIsRunning;
  final int currentTutorialStep;

  const AddExerciseButton({
    required this.tutorialIsRunning,
    required this.currentTutorialStep,
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    final CnAllExercisesPanel cnAllExercisesPanel = Provider.of<CnAllExercisesPanel>(context, listen: false);

    AllExercisePanelConfig config = AllExercisePanelConfig(
        validator: ({
          required CnNewExercisePanel cnNewExercise,
          required BuildContext context,
          required String? value
        }){
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.panelExEnterName;
          }
          else if(exerciseNameExistsInWorkout(workout: cnNewWorkout.workout, exerciseName: value)
              // && cnNewExercise.exercise.originalName?.toLowerCase() != value ///commented 20250616 because it was possible to add an existing exercise to the current workout
          ){
            return AppLocalizations.of(context)!.panelExAlreadyExists;
          }
          else if(cnNewExercise.exercise.originalName != cnNewExercise.exercise.name){
            final bool nameExists = cnAllExercisesPanel.exercises.map((ex) => ex.name.toLowerCase()).contains(value.toLowerCase());
            if(nameExists){
              return AppLocalizations.of(context)!.runningWorkoutExerciseAlreadyExistsInTemplates;
            }
          }
          return null;
        },
        onConfirm: (Exercise exercise){
          cnNewWorkout.confirmAddExercise(exercise);
          cnAllExercisesPanel.closePanel(id: AllExercisePanelIds.mainAllExercisesPanel);
        }
    );

    return Padding(
      padding: const EdgeInsets.only(
          top: 10,
      ),
      child: getRowButton(
        key: cnNewWorkout.keyAddExercise,
        context: context,
        minusWidth: 0,
        onPressed: () async{
          if(MediaQuery.of(context).viewInsets.bottom > 0){
            FocusManager.instance.primaryFocus?.unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
          }
          if(context.mounted){
            cnAllExercisesPanel.openPanel(
                config: config,
                id: AllExercisePanelIds.mainAllExercisesPanel,
                context: context
            );
          }
        },
      ),
    );
  }
}