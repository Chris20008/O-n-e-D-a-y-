import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/exercise_name_field/functions/exercise_name_field_validator.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/exercise_name_field/functions/on_exercise_name_field_submitted.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExerciseNameField extends StatelessWidget {
  const ExerciseNameField({super.key});

  @override
  Widget build(BuildContext context) {

    CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
    CnNewWorkOutPanel cnNewWorkOut = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
          alignment: Alignment.bottomLeft,
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 67, left: 16, right: 16),
            child: Form(
              key: cnNewExercise.formKey,
              child: Consumer<CnNewExercisePanel>(
                  builder: (BuildContext context, value, Widget? child) {
                  return TextFormField(
                    focusNode: cnNewExercise.focusNodeTextFieldExerciseName,
                    key: cnNewExercise.keyExerciseName,
                    keyboardAppearance: Brightness.dark,
                    maxLength: 40,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onTap: (){
                      cnNewExercise.currentIndexWeightOrAmount = 1;
                      cnNewExercise.currentIndexFocus = -1;
                    },
                    onFieldSubmitted: (value) async => await onExerciseNameFieldSubmitted(
                        context: context,
                        value: value,
                        cnHomepage: cnHomepage,
                        cnNewExercise: cnNewExercise
                    ),
                    validator: (value) => exerciseNameFieldValidator(
                        context: context,
                        value: value,
                        cnNewExercise: cnNewExercise,
                        cnNewWorkOut: cnNewWorkOut
                    ),
                    style: const TextStyle(
                        fontSize: 20
                    ),
                    controller: cnNewExercise.exerciseNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      labelText: AppLocalizations.of(context)!.name,
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                    ),
                    onChanged: (value){
                      value = value.trim();
                      cnNewExercise.exercise.name = value;
                    },
                  );
                }
              ),
            ),
          )
      ),
    );
  }
}
