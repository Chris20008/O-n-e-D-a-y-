import 'package:objectbox/objectbox.dart';

@Entity()
class ObExercise{
  @Id()
  int id;

  String name;
  List<double> weights;
  List<int> amounts;
  int restInSeconds;
  int? seatLevel;
  String? linkName;

  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts,
    required this.restInSeconds,
    this.seatLevel,
    this.linkName
  });

  ObExercise.fromMap(Map w): this(
      // id: w["id"],
      name: w["name"],
      weights: List<double>.from(List.from(w["weights"]?? [0.0]).map((w) => double.parse(w.toString()))),
      amounts: List<int>.from(List.from(w["amounts"]?? [0.0]).map((a) => int.parse(a.toString()))),
      // amounts: List.from(w["amounts"]?? [0]),
      restInSeconds: w["restInSeconds"]?? 0,
      seatLevel: w["seatLevel"],
      linkName: w["linkName"]
  );
}