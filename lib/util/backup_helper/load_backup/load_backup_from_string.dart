import 'dart:convert';
import 'package:collection/collection.dart';

import '../../../main.dart';
import '../../objectbox/ob_exercise.dart';
import '../../objectbox/ob_sick_days.dart';
import '../../objectbox/ob_workout.dart';
import '../backup_constants.dart';
import '../sync_incoming_workouts_with_local.dart';

Future<bool> loadBackupFromString({required String content, CnHomepage? cnHomepage}) async{
  /// Todo: Improve Performance of split and for loop
  /// They both take long and block the UI when the data is very large
  final result = content.split(workoutSickDaySeparator);
  result.removeWhere((element) => element.trim() == "");

  /// Load Workouts
  final allWorkoutsAsListString = result.first.split(";");
  allWorkoutsAsListString.removeWhere((element) => element.trim() == "");
  final allWorkouts = allWorkoutsAsListString.map((e) => jsonDecode(e));
  List<ObWorkout> allObWorkouts = [];
  for (Map w in allWorkouts){
    ObWorkout? workout = ObWorkout.fromMap(workoutMap: w, withId: true);
    if(workout != null){
      final List<ObExercise> exs = List.from(w["exercises"].map((ex) => ObExercise.fromMap(ex)));
      workout.addExercises(exs);
      allObWorkouts.add(workout);
    }
  }

  final hadDifferences = await syncIncomingWorkoutsWithLocal(allObWorkouts, cnHomepage: cnHomepage);

  /// Load Sick Days
  final allCurrentSickDays = objectbox.sickDaysBox.getAll();
  if (result.length > 1){

    List<String> allCurrentChecksums = allCurrentSickDays.map((sd) => sd.checksum).toList();

    final allSickDaysAsListString = result[1].split(";");
    allSickDaysAsListString.removeWhere((element) => element.trim() == "");
    final allNewSickDays = allSickDaysAsListString.map((e) => jsonDecode(e));
    final List<ObSickDays> allNewObSickDays = List.from(allNewSickDays.map((m) => ObSickDays.fromMap(sickDaysMap: m)));
    for(ObSickDays sd in allNewObSickDays){
      if(allCurrentChecksums.contains(sd.currentChecksum)){
        allCurrentChecksums.remove(sd.currentChecksum);
        continue;
      }
      await sd.save();
    }
    for(String checksum in allCurrentChecksums){
      allCurrentSickDays.firstWhereOrNull((sd) => sd.checksum == checksum)?.delete();
    }
  } else{
    for(ObSickDays sd in allCurrentSickDays){
      sd.delete();
    }
  }


  /// return if thee was any difference in the current database compared to teh backup
  return hadDifferences;
}