import 'package:flutter/cupertino.dart';
import 'package:quiver/iterables.dart';

import '../util/objectbox/ob_exercise.dart';

class Exercise{

  String name;
  List<SingleSet> sets;
  int restInSeconds;
  int? seatLevel;
  int id;

  String? originalName;
  String? linkName;


  Exercise({
    this.name = "",
    this.sets = const [],
    this.restInSeconds = 0,
    this.seatLevel,
    this.id = -100,
    this.originalName,
    this.linkName
  }){
    if (sets.isEmpty){
      sets = [];
      addSet();
    }
  }

  /// Don't clone the original name
  Exercise.copy(Exercise ex): this(
      name: ex.name,
      sets: List.from(ex.sets.map((set) => SingleSet(weight: set.weight, amount: set.amount, setType: set.setType))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
      linkName: ex.linkName
  );

  Exercise.clone(Exercise ex): this(
      id: ex.id,
      name: ex.name,
      sets: List.from(ex.sets.map((set) => SingleSet(weight: set.weight, amount: set.amount, setType: set.setType))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
      linkName: ex.linkName
  );

  ObExercise toObExercise(){
    List<double> weights = [];
    List<int> amounts = [];
    List<int> setTypes = [];
    sets = sets.where((set) => set.weight != null && set.amount != null).toList();
    for (SingleSet set in sets){
      weights.add(set.weight!);
      amounts.add(set.amount!);
      setTypes.add(set.setType?? 0);
    }
    return ObExercise(
        name: name,
        weights: weights,
        amounts: amounts,
        setTypes: setTypes,
        restInSeconds: restInSeconds,
        seatLevel: seatLevel,
        linkName: linkName
    );
  }

  List<Key> generateKeyForEachSet(){
    return sets.map((e) => UniqueKey()).toList();
  }

  void addSet({double? weight, int? amount, int? setType}){
    sets.add(SingleSet(weight: weight, amount: amount, setType: setType));
  }

  void resetSets({required bool keepSetType}){
    if(keepSetType){
      sets = sets.map((e) => SingleSet(weight:null, amount:null, setType:e.setType)).toList();
    }
    else{
      sets = sets.map((e) => SingleSet(weight:null, amount:null, setType:null)).toList();
    }
  }

  void removeEmptySets(){
    sets = sets.where((e) => e.weight != null && e.amount != null && e.weight! >= 0 && e.amount! > 0).toList();
  }
  
  Map asMap(){
    return {
    "name": name,
    "sets": sets.map((e) => [e.weight, e.amount, e.setType]).toList(),
    "restInSeconds": restInSeconds,
    "seatLevel": seatLevel,
    "originalName": originalName, 
    "linkName": linkName
    };
  }

  Exercise? fromMap(Map data){
    if(
      !data.containsKey("name") ||
        !data.containsKey("sets")||
        !data.containsKey("restInSeconds")||
        !data.containsKey("seatLevel")||
        !data.containsKey("originalName")||
        !data.containsKey("linkName")){
      return null;
    }
    /// setType was added afterwards
    /// So in order to be able to load a backup which doesn't contain this field
    /// we check if alls lists inside sets have a length > 2
    /// When all do so, it means that for all values a setType exists
    /// if not we fill setType with 0 which is the default value
    int? fillSetType;
    for (dynamic val in data["sets"]){
      if (val is List){
        if (val.length > 2){
          continue;
        }
        else{
          fillSetType = 0;
          break;
        }
      }
    }
    print("FILL SET TYPE: $fillSetType");
    return Exercise(
      name: data["name"],
      sets: List<SingleSet>.from(data["sets"].map((s) => SingleSet(weight: s[0], amount: s[1], setType: fillSetType?? s[2]))),
      restInSeconds: data["restInSeconds"],
      seatLevel: data["seatLevel"],
      originalName: data["originalName"],
      linkName: data["linkName"],
    );
  }

  bool equals(Exercise ex){
    if(ex.sets.length != sets.length){
      return false;
    }
    for(List<SingleSet> s in zip([ex.sets, sets])){
      if(!s[0].equals(s[1])){
        return false;
      }
    }
    return seatLevel == ex.seatLevel && restInSeconds == ex.restInSeconds;
  }

}

class SingleSet{
  double? weight;
  int? amount;
  int? setType;

  SingleSet({
    this.weight,
    this.amount,
    this.setType
  });

  bool equals(SingleSet s){
    return weight == s.weight && amount == s.amount && setType == s.setType;
  }
}

class StatisticExercise{
  String name;
  double weight;
  int amount;
  DateTime date;
  StatisticExercise({
    required this.name,
    required this.weight,
    required this.amount,
    required this.date
  });
}

class DismissedSingleSet{
  String? linkName;
  String exName;
  int index;
  SingleSet dismissedSet;
  SingleSet dismissedTemplateSet;
  List<TextEditingController>? dismissedControllers;

  DismissedSingleSet({
    this.linkName,
    required this.exName,
    required this.index,
    required this.dismissedSet,
    required this.dismissedTemplateSet,
    required this.dismissedControllers
  });
}