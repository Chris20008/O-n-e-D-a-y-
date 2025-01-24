import 'package:objectbox/objectbox.dart';

@Entity()
class ObExercise{
  @Id()
  int id;

  String name;
  List<double> weights;
  List<int> amounts;
  List<int> setTypes;
  int restInSeconds;
  int? seatLevel;
  String? linkName;
  int category;
  bool blockLink;

  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts,
    required this.restInSeconds,
    required this.setTypes,
    this.seatLevel,
    this.linkName,
    this.category = 1,
    this.blockLink = false
  });

  factory ObExercise.fromMap(Map w){
    final weights = List<double>.from(List.from(w["weights"]?? [0.0]).map((w) => double.parse(w.toString())));
    return ObExercise(
        name:w["name"],
        weights: weights,
        amounts: List<int>.from(List.from(w["amounts"]?? List.generate(weights.length, (item) => 0)).map((a) => int.parse(a.toString()))),
        setTypes: List<int>.from(List.from(w["setTypes"]?? List.generate(weights.length, (item) => 0)).map((a) => int.parse(a.toString()))),
        restInSeconds: w["restInSeconds"]?? 0,
        seatLevel: w["seatLevel"],
        linkName: w["linkName"],
        category: w["category"]?? 1,
        blockLink: w["blockLink"]?? false
    );
  }

  Map asMap(){
    Map m = {
      "id": id,
      "name": name,
      "weights": weights,
      "amounts": amounts,
      "setTypes": setTypes,
      "restInSeconds": restInSeconds,
      "seatLevel": seatLevel,
      "linkName": linkName,
      "category": category,
      "blockLink": blockLink
    };
    if(m["category"] == 1){
      m.remove("category");
    }
    if(m["seatLevel"] == 0 || m["seatLevel"] == null){
      m.remove("seatLevel");
    }
    if(m["linkName"] == "" || m["linkName"] == null){
      m.remove("linkName");
    }
    if(m["restInSeconds"] == 0){
      m.remove("restInSeconds");
    }
    if(!blockLink){
      m.remove("blockLink");
    }
    return m;
  }

  int getHash(){
    final listHashW = Object.hashAll(weights);
    final listHashA = Object.hashAll(amounts);
    final listHashS = Object.hashAll(setTypes);
    return Object.hash(name, restInSeconds, seatLevel, linkName, listHashW, listHashA, listHashS, category, blockLink);
  }

  bool equals(ObExercise ex){
    return getHash() == ex.getHash();
  }
}