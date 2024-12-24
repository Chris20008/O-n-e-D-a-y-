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

  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts,
    required this.restInSeconds,
    required this.setTypes,
    this.seatLevel,
    this.linkName
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
        linkName: w["linkName"]
    );
  }

  int getHash(){
    final listHashW = Object.hashAll(weights);
    final listHashA = Object.hashAll(amounts);
    final listHashS = Object.hashAll(setTypes);
    return Object.hash(name, restInSeconds, seatLevel, linkName, listHashW, listHashA, listHashS);
  }

  bool equals(ObExercise ex){
    return getHash() == ex.getHash();
  }
}