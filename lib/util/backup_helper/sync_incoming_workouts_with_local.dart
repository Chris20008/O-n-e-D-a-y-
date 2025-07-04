import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/service/sync_manager.dart';

import '../objectbox/ob_exercise.dart';
import '../objectbox/ob_workout.dart';

Future<bool> syncIncomingWorkoutsWithLocal(List<ObWorkout> workouts, {CnHomepage? cnHomepage}) async{
  if(cnHomepage != null && cnHomepage.msg.isEmpty){
    cnHomepage.msg = "Load Backup";
  }
  int batchSize = (workouts.length~/100).clamp(5, 15);
  // int batchSize = 10;
  int counter = 0;
  bool hadDifferences = false;
  List<ObWorkout> allCurrentWorkouts = await objectbox.workoutBox.getAllAsync();
  Map<int, ObWorkout> hashMapBig = {};
  for (var obWorkout in allCurrentWorkouts) {
    final key = obWorkout.getHash();
    hashMapBig[key] = obWorkout;
  }

  Map<int, ObWorkout> hashMapSmall = {};
  for (var obWorkout in allCurrentWorkouts) {
    final key = obWorkout.getHashId();
    hashMapSmall[key] = obWorkout;
  }
  final length = workouts.length;

  for(ObWorkout wo in workouts){

    final woHashSmall = wo.getHashId();
    final woHashBig = wo.getHash();

    /// ################################################################################################################
    /// ################################################################################################################
    ///                                     Workout with same ID, name and Date
    /// ################################################################################################################
    /// ################################################################################################################

    /// Find an existing workout with same id, name and date
    ObWorkout? existingWorkout = hashMapSmall[woHashSmall];

    /// When this workout exists and they are not completely the same (compare HashKeyBig) we can modify the workout without the need to add a new one
    if(existingWorkout != null && !hashMapBig.keys.contains(woHashBig)){
      allCurrentWorkouts.remove(existingWorkout);
      List<ObExercise> allUpdateableExercises = existingWorkout.exercises;

      for(ObExercise ex in wo.exercises){

        /// Since each Exercise name is only allowed once per Workout
        /// we try to find the ex name in the existingWorkouts Exercises
        ObExercise? existingExercise = allUpdateableExercises.firstWhereOrNull((element) => element.name == ex.name);

        /// When an exercise with this name exists and is not equal to the current one, we update it
        if(existingExercise != null && !existingExercise.equals(ex)){
          allUpdateableExercises.remove(existingExercise);
          ex.id = existingExercise.id;
          objectbox.exerciseBox.put(ex);
        }
        /// No ex with this name found -> new Exercise
        else{
          objectbox.exerciseBox.put(ex);
        }
      }

      if(allUpdateableExercises.isNotEmpty){
        await objectbox.exerciseBox.removeManyAsync(allUpdateableExercises.map((e) => e.id).toList());
      }

      existingWorkout = wo;

      await wo.saveAsync();
      hadDifferences = true;
      // continue;
    }

    /// ################################################################################################################
    /// ################################################################################################################
    ///                                         Workout new or exactly same
    /// ################################################################################################################
    /// ################################################################################################################

    else{
      /// If not it means the id does not exists, but maybe the workout itself exists because objectbox entries
      /// on different devices can have different id's
      /// So we check just for equal through the bigHash
      ObWorkout? existingWorkout = hashMapBig[woHashBig];

      /// However, if there is no existing workout that equals the new workout, even when ignoring the ID
      /// It means this is a completely new workout
      if(existingWorkout == null){
        hadDifferences = true;
        wo.id = 0;
        await wo.saveAsync();
        /// Add it to the HashMap in case there is an exact same workout
        hashMapBig[woHashBig] = wo;
      }
      /// This workout exists as it is
      else{
        allCurrentWorkouts.remove(existingWorkout);
      }
    }

    counter += 1;
    /// Await a small delay after each completed Batch to allow the UI to refresh
    /// For better performance this whole function should be executed in an Isolate
    /// Will be implemented later
    if(counter % batchSize == 0){
      await Future.delayed(const Duration(milliseconds: 5));
    }

    if(cnHomepage != null && counter % (batchSize*2) == 0){
      final p = counter / length;
      cnHomepage.updateSyncStatus(p);
    }
  }

  if(allCurrentWorkouts.isNotEmpty){
    hadDifferences = true;
  }

  if(cnHomepage != null){
    final p = counter / length;
    cnHomepage.updateSyncStatus(p);
  }

  objectbox.exerciseBox.removeMany(allCurrentWorkouts.map((w) => w.exercises).expand((element) => element).map((e) => e.id).toList());
  objectbox.workoutBox.removeMany(allCurrentWorkouts.map((w) => w.id).toList());
  for(ObWorkout wo in allCurrentWorkouts){
    await CnSyncManager.database?.deleteCollectionObject(object: wo);
  }
  if(cnHomepage != null){
    cnHomepage.finishSync();
  }
  return hadDifferences;
}