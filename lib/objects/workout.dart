import 'package:flutter/foundation.dart';
import 'package:quiver/iterables.dart';

import '../main.dart';
import '../objectbox.g.dart';
import '../util/objectbox/ob_exercise.dart';
import '../util/objectbox/ob_workout.dart';
import 'exercise.dart';

class Workout{

  String name;
  List<Exercise> exercises;
  DateTime? date;
  int id;
  bool isTemplate;
  /// holds the names of exercise links/groups
  List<String> linkedExercises;

  Workout({
    this.name = "",
    this.exercises = const [],
    this.date,
    this.id = -100,
    this.isTemplate = false,
    this.linkedExercises = const []
  }){
    if(exercises.isEmpty){
      exercises = [];
    }
    if(linkedExercises.isEmpty){
      linkedExercises = [];
    }
    date ??= DateTime.now();
  }

  Workout.clone(Workout w): this(
    name: w.name,
    exercises: w.exercises.map((e) => Exercise.clone(e)).toList(),
    date: w.date,
    linkedExercises: List.from(w.linkedExercises),

    id: w.id,
    isTemplate: w.isTemplate
  );

  Workout.copy(Workout w): this(
      name: w.name,
      exercises: w.exercises.map((e) => Exercise.copy(e)).toList(),
      date: w.date,
      linkedExercises: List.from(w.linkedExercises)
  );
  
  Workout.fromObWorkout(ObWorkout w): this(
      name: w.name,
      exercises: List.from(w.exercises.map((e) => Exercise(
          id: e.id,
          name: e.name,
          sets: List.from(zip([e.weights, e.amounts, e.setTypes]).map((set) => SingleSet(weight: set[0].toDouble(), amount: set[1].toInt(), setType: set[2].toInt()))),
          restInSeconds: e.restInSeconds,
          seatLevel: e.seatLevel,
          linkName: e.linkName,
          category: e.category,
          blockLink: e.blockLink,
          bodyWeightPercent: e.bodyWeightPercent
      ))),
      date: w.date,
      id: w.id,
      isTemplate: w.isTemplate,
      linkedExercises: List.from(w.linkedExercises)
  );

  /// Updates the template workout with same name as THIS workout with THIS workouts exercises
  void updateTemplate(){
    /// Query the database to find the template workout with the given name
    ObWorkout? template = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(true).and(ObWorkout_.name.equals(name))).build().findUnique();
    if(template != null){
      /// Find new exercises that are not already included in the template
      List<Exercise> newExercises = exercises.where((ex) => !template.exercises.map((element) => element.name).contains(ex.name)).toList();

      /// Update existing exercises in the template
      for (ObExercise ex in template.exercises){
        /// Check if the current exercise exists in the new exercises list
        if(exercises.map((e) => e.name).toList().contains(ex.name)) {
          /// Find the corresponding new exercise
          ObExercise newExercise = exercises.where((element) => ex.name == element.name).first.toObExercise();
          /// Update amounts and weights of the existing exercise in the template
          ex.amounts = newExercise.amounts;
          ex.weights = newExercise.weights;
          ex.setTypes = newExercise.setTypes;
          ex.restInSeconds = newExercise.restInSeconds;
          ex.seatLevel = newExercise.seatLevel;
          ex.category = newExercise.category;
          ex.blockLink = newExercise.blockLink;
          ex.bodyWeightPercent = newExercise.bodyWeightPercent;
          /// Put the updated exercise in the database
          objectbox.exerciseBox.put(ex, mode: PutMode.update);
        }
      }
      /// Add new exercises to the template
      for (Exercise ex in newExercises){
        /// Convert Exercise to ObExercise
        ObExercise obExercise = ex.toObExercise();

        if(obExercise.linkName != null){
          final insertIndex = template.exercises.lastIndexWhere((element) => element.linkName == obExercise.linkName) + 1;
          template.exercises.insert(insertIndex, obExercise);
          Workout.fromObWorkout(template).saveToDatabase();
          return;
        }
        else{
          /// Add the new exercise to the template
          template.exercises.add(obExercise);
        }
        /// Put the new exercise in the database
        objectbox.exerciseBox.put(obExercise);
      }

      template.save();
    }
  }


  void refreshDate(){
    date = DateTime.now();
  }

  // List<Key> generateKeysTotalAmountSets(){
  //   List<Key> keys = [];
  //   for (var ex in exercises) {
  //     keys.addAll(ex.generateKeyForEachSet());
  //   }
  //   return keys;
  // }

  ObWorkout toEmptyObWorkout() {
    return ObWorkout(
      name: name,
      date: date!,
      isTemplate: isTemplate,
      linkedExercises: List.from(linkedExercises)
    );
  }

  void resetAllExercisesSets({required bool keepSetType}){
    for (Exercise e in exercises){
      e.resetSets(keepSetType: keepSetType);
    }
  }

  void removeEmptyExercises(){
    exercises = exercises.where((e) {
      e.removeEmptySets();
      return e.sets.isNotEmpty;
    }).toList();
  }

  void addOrUpdateExercise(Exercise exercise){
    List<String> existingExercises = exercises.map((e) => e.name).toList();
    if(exercise.originalName != null && existingExercises.contains(exercise.originalName)){
      final index = existingExercises.indexOf(exercise.originalName!);
      exercises[index] = exercise;
    }
    else{
      exercises.add(
          exercise
      );
    }
  }

  bool isNewWorkout(){
    return id == -100;
  }

  void removeEmptyLinksFromWorkout(){
    linkedExercises = linkedExercises.where((linkName) {
      return exercises.any((exercise) => exercise.linkName == linkName);
    }).toList();
  }

  bool equals(Workout w){
    if(w.exercises.length != exercises.length){
      return false;
    }
    for(List<Exercise> e in zip([w.exercises, exercises])){
      if(!e[0].equals(e[1])){
        return false;
      }
    }
    return w.name == name && w.date == date && w.isTemplate == isTemplate && listEquals(w.linkedExercises, linkedExercises);
  }

  bool isEmpty(){
    return name == '' && exercises.isEmpty && linkedExercises.isEmpty;

  }

  void saveToDatabase(){
    removeEmptyLinksFromWorkout();
    /// checks if workout exists
    ObWorkout? existingObWorkout = objectbox.workoutBox.query(ObWorkout_.id.equals(id)).build().findUnique();

    /// workout already exists
    if(existingObWorkout != null){
      /// find and delete all exercises from this workout
      /// this is necessary to be able to change the order, since objectbox returns the exercises ordered by ID
      List<ObExercise> oldObExercises = existingObWorkout.exercises;
      objectbox.exerciseBox.removeMany(oldObExercises.map((e) => e.id).toList());
      existingObWorkout.name = name;
      if(date != null){
        existingObWorkout.date = date!;
      }
      existingObWorkout.linkedExercises = List.from(linkedExercises);
    }

    List<ObExercise> newObExercises = exercises.map((e) => e.toObExercise()).toList();
    ObWorkout newObWorkout = existingObWorkout?? toEmptyObWorkout();
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
  
  Map asMap(){
    return {
      "id": id,
      "name": name,
      "date": date.toString(),
      "isTemplate": isTemplate,
      "linkedExercises": List.from(linkedExercises),
      "exercises": exercises.map((e) => e.asMap()).toList()
    };
  }

  Workout? fromMap(Map data){
    if(
      !data.containsKey("id") ||
      !data.containsKey("name")||
      !data.containsKey("date")||
      !data.containsKey("isTemplate")||
      !data.containsKey("linkedExercises")||
      !data.containsKey("exercises")){
      return null;
    }
    return Workout(
      id: data["id"],
      name: data["name"],
      date: DateTime.parse(data["date"]),
      isTemplate: data["isTemplate"],
      linkedExercises: List<String>.from(data["linkedExercises"]),
      exercises: List<Exercise>.from(data["exercises"].map((e) => Exercise().fromMap(e)))
    );
  }
}