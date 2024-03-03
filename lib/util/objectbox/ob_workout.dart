import 'package:fitness_app/main.dart';
// import 'package:fitness_app/util/objectbox/ob_link_exercise.dart';
import 'package:objectbox/objectbox.dart';
import 'ob_exercise.dart';

@Entity()
class ObWorkout{
  @Id()
  int id;

  String name;
  @Property(type: PropertyType.date)
  DateTime date;
  bool isTemplate;

  ObWorkout({
    this.id = 0,
    required this.name,
    required this.date,
    required this.isTemplate
  });

  final exercises = ToMany<ObExercise>();
  // final linkExercises = ToMany<ObLinkExercise>();

  void deleteAllExercises(){
    List<int> obExercises = exercises.map((ex) => ex.id).toList();
    objectbox.exerciseBox.removeMany(obExercises);
    // exercises.clear();
    print("Exercises length ${exercises.length}");
  }

  void addExercises(List<ObExercise> newExercises){
    exercises.addAll(newExercises);
    exercises.forEach((element) {
      print(element.id);
    });
  }

  void save(){
    objectbox.workoutBox.put(this);
    objectbox.exerciseBox.putMany(exercises);
    for(ObExercise e in exercises){
      print(e.name);
    }
    print("Exercises length ${exercises.length}");
  }

}