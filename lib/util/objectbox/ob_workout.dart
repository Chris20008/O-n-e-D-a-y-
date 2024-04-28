import 'package:fitness_app/main.dart';
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
  List<String> linkedExercises;

  ObWorkout({
    this.id = 0,
    required this.name,
    required this.date,
    required this.isTemplate,
    this.linkedExercises = const []
  }){
    if(linkedExercises.isEmpty){
      linkedExercises = [];
    }
  }

  ObWorkout.fromMap(Map w): this(
      // id: w["id"],
      name: w["name"],
      date: DateTime.parse(w["date"]),
      isTemplate: w["isTemplate"],
      linkedExercises: List.from(w["linkedExercises"])
  );

  final exercises = ToMany<ObExercise>();

  void deleteAllExercises(){
    List<int> obExercises = exercises.map((ex) => ex.id).toList();
    objectbox.exerciseBox.removeMany(obExercises);
    // exercises.clear();
    print("Exercises length ${exercises.length}");
  }

  void addExercises(List<ObExercise> newExercises){
    exercises.addAll(newExercises);
  }

  void save(){
    objectbox.workoutBox.put(this);
    objectbox.exerciseBox.putMany(exercises);
  }

  Map asMap(){
    final exs = List<Map>.from(exercises.map((ex) => {
      "id": ex.id,
      "name": ex.name,
      "weights": ex.weights,
      "amounts": ex.amounts,
      "restInSeconds": ex.restInSeconds,
      "seatLevel": ex.seatLevel,
      "linkName": ex.linkName
    }));
    final result = {
      "id": id,
      "name": name,
      "date": date.toString(),
      "isTemplate": isTemplate,
      "linkedExercises": linkedExercises,
      "exercises": exs
    };
    return result;
  }
}