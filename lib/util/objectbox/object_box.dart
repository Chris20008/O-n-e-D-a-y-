import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import '../../objectbox.g.dart';
import 'ob_exercise.dart';
import 'ob_workout.dart';

class ObjectBox{
  late final Store store;

  late final Box<ObWorkout> workoutBox;
  late final Box<ObExercise> exerciseBox;
  late final Box<ObSickDays> sickDaysBox;
  static bool initialized = false;

  ObjectBox._create(this.store){
    workoutBox = Box<ObWorkout>(store);
    exerciseBox = Box<ObExercise>(store);
    sickDaysBox = Box<ObSickDays>(store);
  }

  void closeStore(){
    store.close();
  }

  static Future fillMissingChecksums(Box<ObWorkout> workoutBox) async{
    final List<ObWorkout> woToFillChecksums = workoutBox.query(
        ObWorkout_.checksum.equals("-1")
            .or(ObWorkout_.checksum.equals("")
            .or(ObWorkout_.checksum.isNull())
        )).build().find();
    for(ObWorkout wo in woToFillChecksums){
      await wo.save(onlyWorkout: true, onlyLocal: true);
    }
  }

  static Future<ObjectBox> create({String? directory}) async {
    final String? dic = directory == null? null: (await defaultStoreDirectory()).path + directory;
    // Future<store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: dic);
    initialized = true;
    return ObjectBox._create(store);
  }

}