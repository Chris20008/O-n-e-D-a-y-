import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';

void onLeftSetFieldChanged({
  required String value,
  required int index,
  required CnNewExercisePanel cnNewExercise,
  required Function setModalState,
}) {
  value = value.trim();
  if(value.isNotEmpty){
    value = validateDoubleTextInput(value);
    final newValue = double.tryParse(value);
    cnNewExercise.exercise.sets[index].weight = newValue;
    if(newValue == null){
      cnNewExercise.controllers[index][0].clear();
    } else{
      cnNewExercise.controllers[index][0].text = value;
    }
  }
  else{
    cnNewExercise.exercise.sets[index].weight = null;
  }
  setModalState(() {});
}