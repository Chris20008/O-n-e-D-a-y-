import 'package:objectbox/objectbox.dart';

@Entity()
class ObExercise{
  @Id()
  int id;

  String name;
  List<int> weights;
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
      weights: List.from(w["weights"]?? [0]),
      amounts: List.from(w["amount"]?? [0]),
      restInSeconds: w["restInSeconds"]?? 0,
      seatLevel: w["seatLevel"]?? 0,
      linkName: w["linkName"]?? ""
  );
}