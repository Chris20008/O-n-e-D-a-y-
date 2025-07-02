import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';

void onReorder(
    int oldIndex,
    int newIndex,
    Function setState,
    CnNewExercisePanel cnNewExercise
    ){
  setState(() {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = cnNewExercise.exercise.sets.removeAt(oldIndex);
    cnNewExercise.exercise.sets.insert(newIndex, item);
    final weightAndAmount = cnNewExercise.controllers.removeAt(oldIndex);
    cnNewExercise.controllers.insert(newIndex, weightAndAmount);
  });
}