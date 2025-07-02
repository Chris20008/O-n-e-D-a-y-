import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';

Exercise? getNextItemIfExercise({
  required int index,
  required List<SlidableExerciseOrLink> items
}){
  if(items.length > index + 1 /*&& items[index+1].isExercise*/){
    return items[index+1].exercise;
  }
  return null;
}