import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/service/sync_manager.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import 'ob_exercise.dart';


@Entity()
class ObWorkout{

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
    if(uuid == "-1") {
      uuid = const Uuid().v4();
    }
    lastUpdated ??= date;
  }

  @Id()
  int id;

  String uuid;

  String name;
  @Property(type: PropertyType.date)
  DateTime date;
  @Property(type: PropertyType.date)
  DateTime? lastUpdated;
  bool isTemplate;
  List<String> linkedExercises;
  String checksum;

  List<int> exerciseChecksumSkipIds = [];

  String get currentChecksum {
    final hash = sha256.convert(utf8.encode(checksumString));
    print("----CHEKSUM in current: ${hash.toString()}");
    return hash.toString();
  }

  String get checksumString {
    final buffer = StringBuffer();

    final exs = List<String>.from(exercises.map((ex) => exerciseChecksumSkipIds.contains(ex.id)? "" : ex.checksumString));
    exs.removeWhere((result) => result.isEmpty);

    buffer.write(uuid);
    buffer.write(name);
    buffer.write(date);
    buffer.write(isTemplate);
    buffer.write(linkedExercises.toString());
    buffer.write(exs.toString());

    print("BUFFER STRING: ${buffer.toString()}");
    print("Workout als Map: ${asMap()}");
    print("Länge exercises: ${exercises.length}");

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
        linkedExercises: List.from(workoutMap["linkedExercises"])
      );

      print("Created workout");

      if (withExercises && workoutMap["exercises"] != null) {
        print("Add exercises to workout");
        final List<ObExercise> exercises = List<ObExercise>.from(workoutMap["exercises"].map((data) => ObExercise.fromMap(data)));
        print("created list");
        workout.exercises.addAll(exercises);
      }
      return workout;
    }
    catch (e) {
      print(e);
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

  Future save({bool onlyWorkout = false}) async{
    updateLastUpdated();
    // updateChecksum();
    final oldChecksum = checksum;
    // print("All Exercises 1");
    // exercises.forEach((e){print(e.asMap());});
    // exerciseChecksumSkipIds = exercises.map((ex) => ex.id).toList();
    if(!onlyWorkout){
      objectbox.exerciseBox.putMany(exercises);
    }
    // print("All Exercises 2");
    // exercises.forEach((e){print(e.asMap());});
    // updateChecksum();
    final newId = objectbox.workoutBox.put(this);
    // print("All Exercises 3");
    // exercises.forEach((e){print(e.asMap());});

    final newWorkout = objectbox.workoutBox.get(newId);
    // print("All Exercises 4");
    // newWorkout?.exercises.forEach((e){print(e.asMap());});
    print("EVAL CHECKSUM");
    print(oldChecksum);
    print(checksum);
    if(newWorkout != null){
      newWorkout.updateChecksum();
      objectbox.workoutBox.putAsync(newWorkout);
      if(newWorkout.checksum != oldChecksum){
        await CnSyncManager.database?.addWorkout(wo: newWorkout, oldChecksum: oldChecksum);
      }
      // newWorkout.updateChecksum();
      // objectbox.workoutBox.putAsync(newWorkout);
      // CnSyncManager.database?.addWorkout(wo: newWorkout, oldChecksum: oldChecksum);
    }
    // exerciseChecksumSkipIds.clear();
  }

  Future saveAsync({bool onlyWorkout = false}) async{
    updateLastUpdated();
    // updateChecksum();
    final oldChecksum = checksum;
    // print("All Exercises 1");
    // exercises.forEach((e){print(e.asMap());});
    // exerciseChecksumSkipIds = exercises.map((ex) => ex.id).toList();
    if(!onlyWorkout){
      await objectbox.exerciseBox.putManyAsync(exercises);
    }
    // print("All Exercises 2");
    // exercises.forEach((e){print(e.asMap());});
    // updateChecksum();
    final newId = await objectbox.workoutBox.putAsync(this);
    // print("All Exercises 3");
    // exercises.forEach((e){print(e.asMap());});

    final newWorkout = objectbox.workoutBox.get(newId);
    // print("All Exercises 4");
    // newWorkout?.exercises.forEach((e){print(e.asMap());});
    print("EVAL CHECKSUM");
    print(oldChecksum);
    print(checksum);
    if(newWorkout != null){
      newWorkout.updateChecksum();
      objectbox.workoutBox.putAsync(newWorkout);
      if(newWorkout.checksum != oldChecksum){
        await CnSyncManager.database?.addWorkout(wo: newWorkout, oldChecksum: oldChecksum);
      }
    }
    // exerciseChecksumSkipIds.clear();
  }

  void updateLastUpdated(){
    lastUpdated = DateTime.now();
  }

  void updateChecksum(){
    print("Update checksum");
    print("Old $checksum");
    checksum = currentChecksum;
    print("new $checksum");
  }

  int getHash(){
    final listHash = Object.hashAll(linkedExercises);
    final listHashEx = Object.hashAll(exercises.map((element) => element.getHash()));
    return Object.hash(name, date, isTemplate, listHash, listHashEx);
  }

  int getHashId(){
    return Object.hash(id, name, date);
  }

  // static fromServerMap(Map data){
  //   final obWorkout = ObWorkout(
  //       id: data["id"],
  //       uuid: data["uuid"],
  //       name: data["name"],
  //       date: DateTime.parse(data["date"]),
  //       isTemplate: data["isTemplate"],
  //       linkedExercises: List<String>.from(data["linkedExercises"])
  //   );
  //   return
  // }

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
}