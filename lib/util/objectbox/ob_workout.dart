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

  ObWorkout.fromMap({required Map workoutMap, bool withId = false}): this(
      id: withId? workoutMap["id"]?? 0 : 0,
      name: workoutMap["name"],
      date: DateTime.parse(workoutMap["date"]),
      isTemplate: workoutMap["isTemplate"],
      linkedExercises: List.from(workoutMap["linkedExercises"])
  );

  final exercises = ToMany<ObExercise>();

  void deleteAllExercises(){
    List<int> obExercises = exercises.map((ex) => ex.id).toList();
    objectbox.exerciseBox.removeMany(obExercises);
  }

  void addExercises(List<ObExercise> newExercises){
    exercises.addAll(newExercises);
  }

  void save(){
    objectbox.workoutBox.put(this);
    objectbox.exerciseBox.putMany(exercises);
  }

  int getHash(){
    final listHash = Object.hashAll(linkedExercises);
    final listHashEx = Object.hashAll(exercises.map((element) => element.getHash()));
    return Object.hash(name, date, isTemplate, listHash, listHashEx);
  }

  int getHashId(){
    return Object.hash(id, name, date);
  }

  Map asMap(){
    final exs = List<Map>.from(exercises.map((ex) => {
      "id": ex.id,
      "name": ex.name,
      "weights": ex.weights,
      "amounts": ex.amounts,
      "setTypes": ex.setTypes,
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