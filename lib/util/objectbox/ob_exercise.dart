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

  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts,
    required this.restInSeconds,
    this.seatLevel
  });

  // final workout = ToMany<ObWorkout>(); // Beziehung zu Workout

}