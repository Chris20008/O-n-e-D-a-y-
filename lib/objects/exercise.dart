import 'package:flutter/cupertino.dart';

import '../util/objectbox/ob_exercise.dart';

class Exercise{

  String name;
  List<Set> sets;
  int restInSeconds;
  int? seatLevel;

  String? originalName;


  Exercise({
    this.name = "",
    this.sets = const [],
    this.restInSeconds = 0,
    this.seatLevel,
    this.originalName
  }){
    if (sets.isEmpty){
      sets = [];
      addSet();
    }
  }

  /// Don't clone the original name
  Exercise.clone(Exercise ex): this(
      name: ex.name,
      sets: List.from(ex.sets.map((set) => Set(weight: set.weight, amount: set.amount))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
  );

  ObExercise toObExercise(){
    List<int> weights = [];
    List<int> amounts = [];
    sets = sets.where((set) => set.weight != null && set.amount != null).toList();
    for (Set set in sets){
      weights.add(set.weight!);
      amounts.add(set.amount!);
    }
    return ObExercise(
        name: name,
        weights: weights,
        amounts: amounts,
        restInSeconds: restInSeconds,
        seatLevel: seatLevel
    );
  }

  List<Key> generateKeyForEachSet(){
    return sets.map((e) => UniqueKey()).toList();
  }

  void addSet({int? weight, int? amount}){
    sets.add(Set(weight: weight, amount: amount));
  }

  void resetSets(){
    sets = sets.map((e) => Set(weight:-1, amount:-1)).toList();
  }

  void clearEmptySets(){
    sets = sets.where((e) => e.weight != null && e.amount != null && e.weight! >= 0 && e.amount! > 0).toList();
  }

}

class Set{
  int? weight;
  int? amount;

  Set({
    this.weight,
    this.amount
  });
}