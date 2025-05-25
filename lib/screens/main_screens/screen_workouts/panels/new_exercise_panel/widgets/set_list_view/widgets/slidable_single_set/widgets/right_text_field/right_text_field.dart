import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'functions/on_right_set_field_changed.dart';

class RightTextField extends StatefulWidget {
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
  State<RightTextField> createState() => _RightTextFieldState();
}

class _RightTextFieldState extends State<RightTextField> {

  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {

    return Container(
      width: widget.cnNewExercise.widthSetWeightAmount,
      height: widget.cnNewExercise.heightSetWeightAmount,
      color: Colors.transparent,
      child: StatefulBuilder(
          builder: (context, setModalState) {
            return TextField(
              focusNode: widget.cnNewExercise.focusNodes[widget.index][1],
              // onSubmitted: (value) async => await onRightSetFieldSubmitted(
              //     context: context,
              //     value: value,
              //     index: widget.index,
              //     cnNewExercise: widget.cnNewExercise,
              //     cnHomepage: widget.cnHomepage,
              //     insetsBottom: widget.insetsBottom,
              //     screenHeight: widget.screenHeight
              // ),
              textInputAction: TextInputAction.next,
              keyboardAppearance: Brightness.dark,
              // key: cnNewExercise.ensureVisibleKeys[index][1],
              key: key,
              maxLength: widget.cnNewExercise.exercise.categoryIsReps()? 3 : 8,
              style: widget.cnNewExercise.exercise.categoryIsReps()
                  ? const TextStyle(fontSize: 18)
                  : getTextStyleForTextField(widget.cnNewExercise.controllers[widget.index][1].text),
              onTap: () async => await onTapField(
                  index: widget.index,
                  insetsBottom: widget.insetsBottom,
                  weightOrAmountIndex: 1,
                  screenHeight: widget.screenHeight,
                  cnNewExercise: widget.cnNewExercise,
                  key: key
              ),
              textAlign: TextAlign.center,
              controller: widget.cnNewExercise.controllers[widget.index][1],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
              ),
              onChanged: (value) => onRightSetFieldChanged(
                  value: value,
                  index: widget.index,
                  cnNewExercise: widget.cnNewExercise,
                  setModalState: setModalState
              ),
            );
          }
      ),
    );
  }
}
