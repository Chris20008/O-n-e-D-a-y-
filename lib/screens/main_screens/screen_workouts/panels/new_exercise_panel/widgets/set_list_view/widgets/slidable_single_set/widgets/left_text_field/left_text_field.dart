import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/functions/on_tap_field.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/widgets/left_text_field/functions/on_left_set_field_changed.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';

class LeftTextField extends StatefulWidget {
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
  State<LeftTextField> createState() => _LeftTextFieldState();

}

class _LeftTextFieldState extends State<LeftTextField>{

  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {

    return Container(
      width: widget.cnNewExercise.widthSetWeightAmount,
      height: widget.cnNewExercise.heightSetWeightAmount,
      color: Colors.transparent,
      child: TextField(
        focusNode: widget.cnNewExercise.focusNodes[widget.index][0],
        // onSubmitted: (value) => onLeftSetFieldSubmitted(
        //     context: context,
        //     value: value,
        //     index: widget.index,
        //     cnNewExercise: widget.cnNewExercise,
        //     insetsBottom: widget.insetsBottom,
        //     screenHeight: widget.screenHeight
        // ),
        textInputAction: TextInputAction.next,
        keyboardAppearance: Brightness.dark,
        // key: cnNewExercise.ensureVisibleKeys[index][0],
        key: key,
        maxLength: widget.cnNewExercise.controllers[widget.index][0].text.contains(".")? 6 : 4,
        style: getTextStyleForTextField(widget.cnNewExercise.controllers[widget.index][0].text),
        onTap: ()async{
          await onTapField(
              index: widget.index,
              insetsBottom: widget.insetsBottom,
              weightOrAmountIndex: 0,
              screenHeight: widget.screenHeight,
              cnNewExercise: widget.cnNewExercise,
              key: key
          );
        },
        textAlign: TextAlign.center,
        controller: widget.cnNewExercise.controllers[widget.index][0],
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
            index: widget.index,
            cnNewExercise: widget.cnNewExercise,
            setModalState: setState
        ),
      )
    );
  }
}
