import 'package:objectbox/objectbox.dart';
import 'ob_exercise.dart';

@Entity()
class ObWorkout{
  @Id()
  int id;

  String name;
  String date;
  // Color c;

  ObWorkout({
    this.id = 0,
    required this.name,
    required this.date
    // required this.c
  });

  final exercises = ToMany<ObExercise>(); // Beziehung zu Exercises

}