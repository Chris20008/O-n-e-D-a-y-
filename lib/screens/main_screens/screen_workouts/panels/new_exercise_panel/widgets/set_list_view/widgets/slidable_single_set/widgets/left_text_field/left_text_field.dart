import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/widgets/left_text_field/functions/on_left_set_field_changed.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/widgets/left_text_field/functions/on_left_set_field_submitted.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';

class LeftTextField extends StatelessWidget {

  final int index;
  final double insetsBottom;
  final double screenHeight;
  final CnNewExercisePanel cnNewExercise;

  const LeftTextField({
    super.key,
    required this.index,
    required this.insetsBottom,
    required this.screenHeight,
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
            focusNode: cnNewExercise.focusNodes[index][0],
            onSubmitted: (value) => onLeftSetFieldSubmitted(
                context: context,
                value: value,
                index: index,
                cnNewExercise: cnNewExercise,
                insetsBottom: insetsBottom,
                screenHeight: screenHeight
            ),
            textInputAction: TextInputAction.next,
            keyboardAppearance: Brightness.dark,
            key: cnNewExercise.ensureVisibleKeys[index][0],
            maxLength: cnNewExercise.controllers[index][0].text.contains(".")? 6 : 4,
            style: getTextStyleForTextField(cnNewExercise.controllers[index][0].text),
            onTap: ()async{
              await onTapField(
                  index: index,
                  insetsBottom: insetsBottom,
                  weightOrAmountIndex: 0,
                  screenHeight: screenHeight,
                  cnNewExercise: cnNewExercise
              );
            },
            textAlign: TextAlign.center,
            controller: cnNewExercise.controllers[index][0],
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
            ),
            onChanged: (value) => onLeftSetFieldChanged(
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
