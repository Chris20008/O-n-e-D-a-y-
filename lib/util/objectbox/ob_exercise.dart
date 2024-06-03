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

  // ObExercise.fromMap(Map w): this(
  //     // id: w["id"],
  //     name: w["name"],
  //     weights: List<double>.from(List.from(w["weights"]?? [0.0]).map((w) => double.parse(w.toString()))),
  //     amounts: List<int>.from(List.from(w["amounts"]?? [0.0]).map((a) => int.parse(a.toString()))),
  //     setType: List<int>.from(List.from(w["setType"]?? [0.0]).map((a) => int.parse(a.toString()))),
  //     restInSeconds: w["restInSeconds"]?? 0,
  //     seatLevel: w["seatLevel"],
  //     linkName: w["linkName"]
  // );
}