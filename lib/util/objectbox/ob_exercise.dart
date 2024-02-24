import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ObExercise{
  @Id()
  int id;

  String name;
  List<int> weights;
  List<int> amounts;

  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts
  });

  final workout = ToMany<ObWorkout>(); // Beziehung zu Workout

}