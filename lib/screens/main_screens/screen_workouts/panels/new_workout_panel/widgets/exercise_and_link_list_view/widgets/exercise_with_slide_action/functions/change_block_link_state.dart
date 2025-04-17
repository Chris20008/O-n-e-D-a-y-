import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';

Future changeBlockLinkState(
    int index,
    CnNewWorkOutPanel cnNewWorkout,
    {int delay = 0}
    ) async {

  await Future.delayed(Duration(milliseconds: delay));

  /// deactivate blocking
  if(cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink){
    cnNewWorkout.exercisesAndLinks[index].exercise!.linkName = null;
    cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink = false;
    /// gives the exercise a potential new link name and order Exercises
    cnNewWorkout.updateExercisesLinks();
  }
  /// activate blocking
  else{
    cnNewWorkout.exercisesAndLinks[index].exercise!.linkName = null;
    cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink = true;
    /// reorder to move to potential new position
    cnNewWorkout.orderExercises();
  }
}