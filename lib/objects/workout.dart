import 'package:flutter/material.dart';

import 'exercise.dart';

class Workout{

  String? name;
  List<Exercise> exercises = [];
  Color c = Colors.blue[300] ?? Colors.blue;

  Workout({
    this.name,
  });

  void addExercise(Exercise exercise){
    exercises.add(
        exercise
    );
  }


}