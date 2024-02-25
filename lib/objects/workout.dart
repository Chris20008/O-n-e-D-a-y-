import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart';

import '../util/objectbox/ob_workout.dart';
import 'exercise.dart';

class Workout{

  String name;
  List<Exercise> exercises;
  Color c = Colors.blue[300] ?? Colors.blue;
  String date;
  int id;

  Workout({
    this.name = "",
    this.exercises = const [],
    this.date = "",
    this.id = -100
  }){
    // name = name;
    if (exercises.isEmpty){
      exercises = [];
    }
    if(date.isEmpty){
      date = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    }
  }

  Workout.clone(Workout w): this(
    name: w.name,
    exercises: w.exercises.map((e) => Exercise.clone(e)).toList(),
    date: w.date,
    id: w.id
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

  ObWorkout toObWorkout() {
    return ObWorkout(
      name: name,
      date: date,
    );
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
}