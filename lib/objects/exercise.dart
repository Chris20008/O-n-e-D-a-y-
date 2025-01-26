import 'package:flutter/cupertino.dart';
import 'package:quiver/iterables.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../util/objectbox/ob_exercise.dart';

Map categoryMapping = {
  1: "Wiederholungen",
  2: "Cardio",
  3: "Static Hold"
};

class Exercise{

  String name;
  List<SingleSet> sets;
  int restInSeconds;
  int? seatLevel;
  int id;

  String? originalName;
  String? linkName;
  int category;
  bool blockLink;


  Exercise({
    this.name = "",
    this.sets = const [],
    this.restInSeconds = 0,
    this.seatLevel,
    this.id = -100,
    this.originalName,
    this.linkName,
    this.category = 1,
    this.blockLink = false
  }){
    if (sets.isEmpty){
      sets = [];
      addSet();
    }
  }

  Exercise.fromObExercise(ObExercise e):this(
      id: e.id,
      name: e.name,
      sets: List.from(zip([e.weights, e.amounts, e.setTypes]).map((set) => SingleSet(weight: set[0].toDouble(), amount: set[1].toInt(), setType: set[2].toInt()))),
      restInSeconds: e.restInSeconds,
      seatLevel: e.seatLevel,
      linkName: e.linkName,
      category: e.category,
      blockLink: e.blockLink
  );

  /// Don't clone the original name
  Exercise.copy(Exercise ex): this(
      name: ex.name,
      sets: List.from(ex.sets.map((set) => SingleSet(weight: set.weight, amount: set.amount, setType: set.setType))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
      linkName: ex.linkName,
      category: ex.category,
      blockLink: ex.blockLink
  );

  Exercise.clone(Exercise ex): this(
      id: ex.id,
      name: ex.name,
      sets: List.from(ex.sets.map((set) => SingleSet(weight: set.weight, amount: set.amount, setType: set.setType))),
      restInSeconds: ex.restInSeconds,
      seatLevel: ex.seatLevel,
      linkName: ex.linkName,
      category: ex.category,
      blockLink: ex.blockLink
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
        linkName: linkName,
        category: category,
        blockLink: blockLink
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
      "linkName": linkName,
      "category": category,
      "blockLink": blockLink
    };
  }

  Exercise? fromMap(Map data){
    if(
      !data.containsKey("name") ||
        !data.containsKey("sets")||
        !data.containsKey("restInSeconds")||
        !data.containsKey("seatLevel")){
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
    return Exercise(
      name: data["name"],
      sets: List<SingleSet>.from(data["sets"].map((s) => SingleSet(weight: s[0], amount: s[1], setType: fillSetType?? s[2]))),
      restInSeconds: data["restInSeconds"],
      seatLevel: data["seatLevel"],
      originalName: data["originalName"],
      linkName: data["linkName"],
      category: data["category"]?? 1,
      blockLink: data['blockLink']?? false
    );
  }

  bool equals(Exercise ex){
    if(ex.name != name ||
        seatLevel != ex.seatLevel ||
        restInSeconds != ex.restInSeconds ||
        ex.sets.length != sets.length ||
        ex.category != category
    ){
      return false;
    }
    for(List<SingleSet> s in zip([ex.sets, sets])){
      if(!s[0].equals(s[1])){
        return false;
      }
    }
    return true;
  }

  bool categoryIsReps(){
    return category == 1;
  }

  bool categoryIsCardio(){
    return category == 2;
  }

  bool categoryIsStaticHold(){
    return category == 3;
  }

  String getCategoryName(){
    return categoryMapping[category];
  }

  String getLeftTitle(BuildContext context){
    if(categoryIsCardio()){
      return "km";
    }
    return AppLocalizations.of(context)!.weight;
  }

  String getRightTitle(BuildContext context){
    if(category == 1){
      return AppLocalizations.of(context)!.amount;
    }
    return "Zeit";
  }

  String getSelectorText(BuildContext context){
    if (categoryIsReps()){
      return "Wiederholungen";
    } else if(categoryIsCardio()){
      return "Cardio";
    } else if(categoryIsCardio()){
      return "Static Hold";
    }else {
      category = 1;
      return "Wiederholungen";
    }
  }

  bool isNewExercise(){
    return id == -100;
  }

}

class SingleSet{
  double? weight;
  int? amount;
  /// set Type 0 = Working set
  /// 1 = Warm Up Set
  /// 11-20 = RPE 1-10
  int? setType;

  SingleSet({
    this.weight,
    this.amount,
    this.setType
  });

  bool equals(SingleSet s){
    return weight == s.weight && amount == s.amount && setType == s.setType;
  }

  dynamic get weightAsTrimmedDouble{
    if(weight == null || weight!%1 != 0){
      return weight;
    }
    return weight?.toInt();
  }

  String? get amountAsTime{
    if(amount == null){
      return null;
    }
    /// if greater 5 digits remove the last until 5
    while(amount! > 99999){
      amount = (amount!/10).floor();
    }
    String timeAsString = amount.toString().padLeft(5, "0");
    if(timeAsString.substring(0, 1) == "0"){
      timeAsString = "${timeAsString.substring(1, 3)}:${timeAsString.substring(3, 5)}";
    }
    else{
      timeAsString = "${timeAsString.substring(0, 1)}:${timeAsString.substring(1, 3)}:${timeAsString.substring(3, 5)}";
    }
    return timeAsString;
  }

  String? getAmountAsText(int category){
    switch (category){
      case 1:
        return (amount?? "").toString();
      case 2:
        return amountAsTime;
      case 3:
        return amountAsTime;
      default:
        return "";
    }
  }

  String get amountAsColumn{
    // List res = amountAsTime?.split(":")?? [];
    String res = amountAsTime?.replaceAll(":", "")?? "00000";
    res = res.padLeft(5, "0");
    String hours = "${int.parse(res.substring(0, 1))}h".replaceFirst("0", "");
    String minutes = "${int.parse(res.substring(1, 3))}m".replaceFirst("0", "");
    String seconds = "${int.parse(res.substring(3, 5))}s".replaceFirst("0", "");
    List<String> parsedValues = [];
    if(hours.length > 1){
      parsedValues.add(hours);
    }
    if(minutes.length > 1){
      parsedValues.add(minutes);
    }
    if(seconds.length > 1){
      parsedValues.add(seconds);
    }
    return parsedValues.join("\n");
    // if(res.substring(0, 1) == "0"){
    //   return "${res[0]}h\n${res[1]}m\n${res[2]}s";
    // }
    // else{
    //   return "${res[0]}m\n${res[1]}s";
    // }
    // if(res.length == 2){
    //   return "${res[0]}m\n${res[1]}s";
    // } else if (res.length == 3){
    //   return "${res[0]}h\n${res[1]}m\n${res[2]}s";
    // }
    // return "";
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