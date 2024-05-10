import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import '../../objectbox.g.dart';
import 'ob_exercise.dart';
import 'ob_workout.dart';

class ObjectBox{
  late final Store store;

  late final Box<ObWorkout> workoutBox;
  late final Box<ObExercise> exerciseBox;

  ObjectBox._create(this.store){
    workoutBox = Box<ObWorkout>(store);
    exerciseBox = Box<ObExercise>(store);
  }

  void closeStore(){
    store.close();
  }

  static Future<ObjectBox> create({String? directory}) async {
    final String? dic = directory == null? null: (await defaultStoreDirectory()).path + directory;
    // Future<store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: dic);
    return ObjectBox._create(store);
  }

}