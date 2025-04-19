import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'functions/on_right_set_field_changed.dart';
import 'functions/on_right_set_field_submitted.dart';

class RightTextField extends StatelessWidget {

  final int index;
  final double insetsBottom;
  final double screenHeight;
  final CnHomepage cnHomepage;
  final CnNewExercisePanel cnNewExercise;

  const RightTextField({
    super.key,
    required this.index,
    required this.insetsBottom,
    required this.screenHeight,
    required this.cnHomepage,
    required this.cnNewExercise
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cnNewExercise.widthSetWeightAmount,
      height: cnNewExercise.heightSetWeightAmount,
      color: Colors.transparent,
      child: StatefulBuilder(
          builder: (context, setModalState) {
          return TextField(
            focusNode: cnNewExercise.focusNodes[index][1],
            onSubmitted: (value) async => await onRightSetFieldSubmitted(
                context: context,
                value: value,
                index: index,
                cnNewExercise: cnNewExercise,
                cnHomepage: cnHomepage,
                insetsBottom: insetsBottom,
                screenHeight: screenHeight
            ),
            textInputAction: TextInputAction.next,
            keyboardAppearance: Brightness.dark,
            key: cnNewExercise.ensureVisibleKeys[index][1],
            maxLength: cnNewExercise.exercise.categoryIsReps()? 3 : 8,
            style: cnNewExercise.exercise.categoryIsReps()
                ? const TextStyle(fontSize: 18)
                : getTextStyleForTextField(cnNewExercise.controllers[index][1].text),
            onTap: () async => await onTapField(
                index: index,
                insetsBottom: insetsBottom,
                weightOrAmountIndex: 1,
                screenHeight: screenHeight,
                cnNewExercise: cnNewExercise
            ),
            textAlign: TextAlign.center,
            controller: cnNewExercise.controllers[index][1],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
            ),
            onChanged: (value) => onRightSetFieldChanged(
                value: value,
                index: index,
                cnNewExercise: cnNewExercise,
                setModalState: setModalState
            ),
          );
        }
      ),
    );
  }
}
