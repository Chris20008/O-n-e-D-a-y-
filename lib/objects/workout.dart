import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../util/objectbox/ob_workout.dart';
import 'exercise.dart';

class Workout{

  String? name;
  List<Exercise> exercises;
  Color c = Colors.blue[300] ?? Colors.blue;

  // Workout({
  //   this.name,
  // });

  Workout({
    this.name = "",
    this.exercises = const []
  }){
    this.name = name;
    if (exercises.isEmpty){
      exercises = [];
    }
  }
  
  Workout.fromObWorkout(ObWorkout w): this(
    name: w.name,
    exercises: List.from(w.exercises.map((e) => Exercise(
        name: e.name,
        // sets: [Set(weight: 10, amount: 10), Set(weight: 20, amount: 10)]
        sets: List.from(zip([e.weights, e.amounts]).map((set) => Set(weight: set[0], amount: set[1])))
    )))
  );

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


}