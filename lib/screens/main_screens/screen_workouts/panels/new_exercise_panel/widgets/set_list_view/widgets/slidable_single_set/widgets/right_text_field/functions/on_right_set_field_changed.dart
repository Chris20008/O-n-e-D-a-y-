import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';

void onRightSetFieldChanged({
  required String value,
  required int index,
  required CnNewExercisePanel cnNewExercise,
  required Function setModalState,
}) {

  value = value.trim();
  /// For Reps
  if(cnNewExercise.exercise.categoryIsReps()){
    if(value.isNotEmpty){
      final newValue = int.tryParse(value);
      cnNewExercise.exercise.sets[index].amount = newValue;
      if(newValue == null){
        cnNewExercise.controllers[index][1].clear();
      }
    }
    else{
      cnNewExercise.exercise.sets[index].amount = null;
    }
  }
  /// For Time
  else{
    List result = parseTextControllerAmountToTime(value);
    cnNewExercise.controllers[index][1].text = result[1];
    cnNewExercise.exercise.sets[index].amount = result[0];
  }
  setModalState(() {});
}