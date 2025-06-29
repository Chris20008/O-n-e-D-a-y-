import 'package:fitness_app/main.dart';
import 'package:fitness_app/service/database_service/collection.dart';
import 'package:fitness_app/service/sync_manager.dart';
import 'package:fitness_app/util/objectbox/abstract_class_firebase_object.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import 'mixin_checksum.dart';
import 'ob_exercise.dart';


@Entity()
class ObWorkout with Checksum implements FirebaseObject{

  /// Id properties
  @override
  @Id()
  int id;
  @override
  String uuid;

  /// Indexed Fields
  @Index()
  String name;
  @override
  @Index()
  String checksum;

  /// Data Fields
  @Property(type: PropertyType.date)
  DateTime date;
  @override
  @Property(type: PropertyType.date)
  DateTime? lastUpdated;
  bool isTemplate;
  List<String> linkedExercises;

  /// Constructor
  ObWorkout({
    this.id = 0,
    this.uuid = '-1',
    this.checksum = '-1',
    required this.name,
    required this.date,
    required this.isTemplate,
    this.linkedExercises = const [],
    this.lastUpdated,
  }){

    if(linkedExercises.isEmpty){
      linkedExercises = [];
    }
    if(uuid == "-1" || uuid.isEmpty) {
      uuid = const Uuid().v4();
    }
    updateLastUpdated();
  }

  @override
  String get checksumString {
    final buffer = StringBuffer();

    final exs = List<String>.from(exercises.map((ex) => ex.checksumString));
    exs.removeWhere((result) => result.isEmpty);

    buffer.write(uuid);
    buffer.write(name);
    buffer.write(date);
    buffer.write(isTemplate);
    buffer.write(linkedExercises.toString());
    buffer.write(exs.toString());

    return buffer.toString();
  }

  static ObWorkout? fromMap({required Map workoutMap, bool withId = false, bool withExercises = false}) {
    try{
      final workout = ObWorkout(
        id: withId ? (workoutMap["id"] ?? 0) : 0,
        uuid: workoutMap["uuid"]?? "-1",
        name: workoutMap["name"]?? "-1",
        date: DateTime.parse(workoutMap["date"]),
        lastUpdated: workoutMap["lastUpdated"] != null
            ? DateTime.parse(workoutMap["lastUpdated"])
            : null,
        isTemplate: workoutMap["isTemplate"],
        linkedExercises: List.from(workoutMap["linkedExercises"]),
        checksum: workoutMap["checksum"]?? '-1'
      );

      if (withExercises && workoutMap["exercises"] != null) {
        final List<ObExercise> exercises = List<ObExercise>.from(workoutMap["exercises"].map((data) => ObExercise.fromMap(data)));
        workout.exercises.addAll(exercises);
      }
      return workout;
    }
    catch (e) {
      pr(e);
      return null;
    }

  }

  final exercises = ToMany<ObExercise>();

  void deleteAllExercises(){
    List<int> obExercises = exercises.map((ex) => ex.id).toList();
    objectbox.exerciseBox.removeMany(obExercises);
  }

  void addExercises(List<ObExercise> newExercises){
    exercises.addAll(newExercises);
  }

  Future delete() async{
    deleteAllExercises();
    objectbox.workoutBox.remove(id);
    await CnSyncManager.database?.deleteWorkout(wo: this);
  }

  @override
  Future save({bool onlyWorkout = false, bool onlyLocal = false}) async{
    pr("Save Workout");
    updateLastUpdated();
    final oldChecksum = checksum;
    if(!onlyWorkout){
      objectbox.exerciseBox.putMany(exercises);
    }
    final newId = objectbox.workoutBox.put(this);

    final newWorkout = objectbox.workoutBox.get(newId);
    if(newWorkout != null){
      newWorkout.updateChecksum();
      objectbox.workoutBox.putAsync(newWorkout);
      pr("Old Checksum $oldChecksum");
      pr("New Checksum ${newWorkout.checksum}");
      pr("");
      if(newWorkout.checksum != oldChecksum && !onlyLocal){
        await CnSyncManager.database?.addWorkout(wo: newWorkout, oldChecksum: oldChecksum);
      }
    }
  }

  Future saveAsync({bool onlyWorkout = false}) async{
    pr("Save Workout");
    updateLastUpdated();
    final oldChecksum = checksum;
    if(!onlyWorkout){
      await objectbox.exerciseBox.putManyAsync(exercises);
    }
    final newId = await objectbox.workoutBox.putAsync(this);

    final newWorkout = objectbox.workoutBox.get(newId);
    if(newWorkout != null){
      newWorkout.updateChecksum();
      objectbox.workoutBox.putAsync(newWorkout);
      pr("Old Checksum $oldChecksum");
      pr("New Checksum ${newWorkout.checksum}");
      pr("");
      if(newWorkout.checksum != oldChecksum){
        await CnSyncManager.database?.addWorkout(wo: newWorkout, oldChecksum: oldChecksum);
      }
    }
  }

  void updateLastUpdated(){
    lastUpdated = DateTime.now();
  }

  void updateChecksum(){
    checksum = currentChecksum;
  }

  int getHash(){
    final listHash = Object.hashAll(linkedExercises);
    final listHashEx = Object.hashAll(exercises.map((element) => element.getHash()));
    return Object.hash(name, date, isTemplate, listHash, listHashEx);
  }

  int getHashId(){
    return Object.hash(id, name, date);
  }

  Map<String, dynamic> asMap({withChecksum = false}){
    final exs = List<Map>.from(exercises.map((ex) => ex.asMap()));
    final result = {
      "id": id,
      "uuid": uuid,
      "name": name,
      "date": date.toString(),
      "isTemplate": isTemplate,
      "linkedExercises": linkedExercises,
      "exercises": exs,
      "lastUpdated": lastUpdated.toString(),
    };
    if(withChecksum){
      result["checksum"] = currentChecksum;
    }
    return result;
  }

  @override
  Collection get collection => Collection.workouts;

  @override
  ObWorkout? firebaseObjectConstructor(Map<String, dynamic> map) {
    return ObWorkout.fromMap(workoutMap: map);
  }
}