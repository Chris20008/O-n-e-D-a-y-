import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';

Future changeBlockLinkState(
    Exercise exercise,
    CnNewWorkOutPanel cnNewWorkout,
    {int delay = 0}
    ) async {

  await Future.delayed(Duration(milliseconds: delay));

  /// deactivate blocking
  if(exercise.blockLink){
    exercise.linkName = null;
    exercise.blockLink = false;
    /// gives the exercise a potential new link name and order Exercises
    cnNewWorkout.updateExercisesLinks();
  }
  /// activate blocking
  else{
    exercise.linkName = null;
    exercise.blockLink = true;
    /// reorder to move to potential new position
    cnNewWorkout.orderExercises();
  }
}