import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/widgets/exercise_name_field/functions/on_exercise_name_field_submitted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExerciseNameField extends StatelessWidget {
  const ExerciseNameField({super.key});

  @override
  Widget build(BuildContext context) {

    CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
    CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

    // final formKey = GlobalKey<FormState>();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
          // alignment: Alignment.bottomLeft,
          color: Theme.of(context).primaryColor,
          height: cnNewExercise.heightHeader,
          // color: Colors.red,
          child: Consumer<CnNewExercisePanel>(
              builder: (BuildContext context, cn, Widget? child) {
              return Padding(
                padding: const EdgeInsets.only(top: 67, left: 16, right: 16),
                child: Form(
                  key: cn.getFormKey(context),
                  child: TextFormField(
                    // focusNode: cnNewExercise.focusNodeTextFieldExerciseName,
                    // key: cnNewExercise.getKeyExerciseName(ExerciseContextId.of(context)),
                    key: cn.getKeyExerciseName(context),
                    keyboardAppearance: Brightness.dark,
                    maxLength: 40,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onTap: (){
                      cn.currentIndexWeightOrAmount = 1;
                      cn.currentIndexFocus = -1;
                    },
                    onFieldSubmitted: (value) async => await onExerciseNameFieldSubmitted(
                        context: context,
                        value: value,
                        cnHomepage: cnHomepage,
                        cnNewExercise: cn
                    ),
                    validator: (value){
                      if(cnNewExercise.exerciseNameFieldValidator != null){
                        return cnNewExercise.exerciseNameFieldValidator!(
                            context: context,
                            value: value,
                            cnNewExercise: cn
                        );
                      }
                      return null;
                    },
                    // validator: (value) => exerciseNameFieldValidator(
                    //     context: context,
                    //     value: value,
                    //     cnNewExercise: cn,
                    //     cnNewWorkOut: cnNewWorkOut
                    // ),
                    style: const TextStyle(
                        fontSize: 20
                    ),
                    controller: cn.exerciseNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      labelText: AppLocalizations.of(context)!.name,
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                    ),
                    onChanged: (value){
                      value = value.trim();
                      cn.exercise.name = value;
                    },
                  ),
                ),
              );
            }
          )
      ),
    );
  }
}
