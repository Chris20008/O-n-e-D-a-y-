import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../main.dart';
import '../objectbox.g.dart';
import '../util/objectbox/ob_exercise.dart';
import '../util/objectbox/ob_workout.dart';
import 'exercise.dart';

class Workout{

  String name;
  List<Exercise> exercises;
  Color c = Colors.blue[300] ?? Colors.blue;
  DateTime? date;
  int id;

  Workout({
    this.name = "",
    this.exercises = const [],
    this.date,
    this.id = -100
  }){
    // name = name;
    if (exercises.isEmpty){
      exercises = [];
    }
    date ??= DateTime.now();
  }

  Workout.clone(Workout w): this(
    name: w.name,
    exercises: w.exercises.map((e) => Exercise.clone(e)).toList(),
    date: w.date,
    id: w.id
  );

  Workout.copy(Workout w): this(
      name: w.name,
      exercises: w.exercises.map((e) => Exercise.clone(e)).toList(),
  );
  
  Workout.fromObWorkout(ObWorkout w): this(
      name: w.name,
      exercises: List.from(w.exercises.map((e) => Exercise(
          name: e.name,
          sets: List.from(zip([e.weights, e.amounts]).map((set) => Set(weight: set[0], amount: set[1]))),
          restInSeconds: e.restInSeconds,
          seatLevel: e.seatLevel
      ))),
      date: w.date,
      id: w.id
  );

  void refreshDate(){
    date = DateTime.now();
  }

  List<Key> generateKeysTotalAmountSets(){
    List<Key> keys = [];
    exercises.forEach((ex) => keys.addAll(ex.generateKeyForEachSet()));
    return keys;
  }

  ObWorkout toObWorkout() {
    return ObWorkout(
      name: name,
      date: date!,
    );
  }

  void resetAllExercisesSets(){
    for (Exercise e in exercises){
      e.resetSets();
    }
  }

  void clearAllExercisesEmptySets(){
    List<Exercise> emptyExercises = [];
    for (Exercise e in exercises){
      e.clearEmptySets();
      if(e.sets.isEmpty){
        emptyExercises.add(e);
      }
    }
  }

  void addOrUpdateExercise(Exercise exercise){
    List<String> existingExercises = exercises.map((e) => e.name).toList();

    if(exercise.originalName != null && existingExercises.contains(exercise.originalName)){
      exercises[existingExercises.indexOf(exercise.originalName!)] = exercise;
    }
    else{
      exercises.add(
          exercise
      );
    }
  }

  void saveToDatabase(){
    /// checks if workout exists
    ObWorkout? existingObWorkout = objectbox.workoutBox.query(ObWorkout_.id.equals(id)).build().findUnique();

    /// workout already exists
    if(existingObWorkout != null){
      /// find and delete all exercises from this workout
      List<ObExercise> oldObExercises = existingObWorkout.exercises;
      objectbox.exerciseBox.removeMany(oldObExercises.map((e) => e.id).toList());
      existingObWorkout.name = name;
    }
    List<ObExercise> newObExercises = exercises.map((e) => e.toObExercise()).toList();
    ObWorkout newObWorkout = existingObWorkout?? toObWorkout();
    newObWorkout.exercises.addAll(newObExercises);
    objectbox.workoutBox.put(newObWorkout);
    objectbox.exerciseBox.putMany(newObExercises);
  }

  void deleteFromDatabase(){
    ObWorkout? w = objectbox.workoutBox.query(ObWorkout_.id.equals(id)).build().findUnique();
    if(w != null){
      List<ObExercise> obExercises = w.exercises;
      objectbox.exerciseBox.removeMany(obExercises.map((e) => e.id).toList());
      objectbox.workoutBox.remove(w.id);
    }
  }
}