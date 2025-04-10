import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:fitness_app/main.dart';

class WorkoutNameField extends StatelessWidget {

  const WorkoutNameField({
    Key? key
    }) : super(key: key);

  String? validateTextInput(
    String? value, 
    CnNewWorkOutPanel cnNewWorkout, 
    BuildContext context
    ) {
    value = value?.trim();
    final nameExists = workoutNameExistsInTemplates(workoutName: cnNewWorkout.workout.name);
    final isTemplate = cnNewWorkout.workout.isTemplate;
    final nameHasChanged = cnNewWorkout.workout.name.toLowerCase() != cnNewWorkout.originalWorkout.name.toLowerCase();
    
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.panelWoEnterName;
    }
    /// Check if the workout name already exists, but only when the current name is different from the
    /// initializing name. Otherwise editing an existing workout could lead to error
    else if(isTemplate   &&           /// only check if template
            nameHasChanged &&         /// Name is not equal to initial name when opening editing
            nameExists                /// Name exists in database
    ){
      return AppLocalizations.of(context)!.panelWoAlreadyExists;
    }
    return null;
  }

  void onTap(CnNewWorkOutPanel cnNewWorkout) async{
    if(cnNewWorkout.panelController.isPanelClosed){
      Future.delayed(const Duration(milliseconds: 300), (){
        HapticFeedback.selectionClick();
        /// We need to use the panel controllers own open methode because, when we use our open
        /// panel method, the keyboard gets dismissed (unfocused) by onPanelSlide() cause for some reason
        /// our methods triggers an exact 0.0 value and the normal panelController.open() methode does not.
        /// Maybe due to speed of opening the panel
        cnNewWorkout.openPanel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    final CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

    return Form(
      key: cnNewWorkout.formKey,
      child: TextFormField(
        focusNode: cnNewWorkout.focusNodeTextFieldWorkoutName,
        textInputAction: tutorialIsRunning ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: tutorialIsRunning ? (value){
          if(tutorialIsRunning && value.isNotEmpty){
            cnHomepage.tutorial?.next();
            blockUserInput(context, duration: 1500);
            FocusManager.instance.primaryFocus?.unfocus();
          }
        } : null,
        key: cnNewWorkout.keyTextFieldWorkoutName,
        keyboardAppearance: Brightness.dark,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => validateTextInput(value, cnNewWorkout, context),
        onTap: () => onTap(cnNewWorkout),
        style: const TextStyle(
          fontSize: 20
        ),
        controller: cnNewWorkout.workoutNameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelText: AppLocalizations.of(context)!.name,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
        ),
        onChanged: (value){
          cnNewWorkout.workout.name = value;
        },
      ),
    );
  }
}