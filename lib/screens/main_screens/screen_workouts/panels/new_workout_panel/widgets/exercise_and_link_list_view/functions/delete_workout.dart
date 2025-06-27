import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../util/backup_helper/save_current_data.dart';

Future deleteWorkout({
  required BuildContext context
}) async{
  CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);

  if(cnNewWorkout.isSickDays){
    cnNewWorkout.sickDays.delete();
  }
  else{
    await cnNewWorkout.workout.deleteFromDatabase();
    cnWorkouts.refreshAllWorkouts();
  }
  cnWorkoutHistory.refreshAllWorkouts();
  cnNewWorkout.closePanel(doClear: true, context: context);
  cnNewExercisePanel.clear();
  saveCurrentData(cnConfig);
}