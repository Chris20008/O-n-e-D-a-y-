import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../util/constants.dart';
import 'database_service.dart';

class CnSyncManager extends ChangeNotifier {
  final String? userId;
  static DatabaseService? database;
  static List<String> localeChecksums = [];

  CnSyncManager(this.userId){
    if(userId != null){
      database = DatabaseService(uid: userId!);
    }
  }

  Future startSyncService() async{
    if(database == null){
      return;
    }
    final serverChecksumsFuture = database!.getServerChecksums();

    localeChecksums = objectbox.workoutBox.getAll().map((w) => w.checksum).toList();
    final ServerChecksums serverChecksums = await serverChecksumsFuture;

    await syncChecksums(serverChecksums: serverChecksums);
  }

  Future syncChecksums({required ServerChecksums serverChecksums}) async {

    pr("");
    pr("localChecksums: $localeChecksums");
    pr("serverChecksums: ${serverChecksums.checksums}");
    pr("");

    final missingLocal = serverChecksums.checksums.without(localeChecksums);
    final missingServer = localeChecksums.without(serverChecksums.checksums);

    pr("");
    pr("MissingLocal: $missingLocal");
    pr("MissingServer: $missingServer");
    pr("");

    /// Remove local workouts that are not on server db
    /// when the lastUpdated is larger than the workouts timestamp
    for (String checksum in missingServer) {
      final woToDelete = objectbox.workoutBox.query(ObWorkout_.checksum.equals(checksum)).build().findFirst();

      if(woToDelete == null){
        continue;
      }

      /// Workout was saved locally after last Server Update
      /// so we add it to server backend
      if(woToDelete.lastUpdated?.isAfter(serverChecksums.lastUpdated) ?? false){
        pr("Workout: ${woToDelete.name} is missing on server side, but newer than last sync. Add it to Server");
        print(woToDelete.lastUpdated);
        print(serverChecksums.lastUpdated);
        print(woToDelete.lastUpdated?.isAfter(serverChecksums.lastUpdated));
        await database!.addWorkout(wo: woToDelete);
      }

      /// Workout was last Updated before the last server update
      /// So this workout is old, remove it from client side
      else{
        pr("Workout: ${woToDelete.name} is missing on server side and older than last sync, remove it from client");
        localeChecksums.remove(checksum);
        objectbox.workoutBox.remove(woToDelete.id);
        objectbox.exerciseBox.removeMany(woToDelete.exercises.map((ex) => ex.id).toList());
      }
    }

    /// Add missing Workouts from Server to local db
    for (String checksum in missingLocal) {
      pr("checksum: $checksum is missing on client, try to fetch it from server");
      final workoutMap = await database!.getWorkoutByChecksum(checksum);
      if(workoutMap != null){
        final ObWorkout? newWo = ObWorkout.fromMap(workoutMap: workoutMap, withExercises: true);

        if(newWo != null){
          pr("Workout: ${newWo.name} was found on serve, add it to client");
          newWo.save();
          localeChecksums.add(checksum);
        }
        /// ToDo: when newWo is null, the map couldn't be parsed
        /// so we have to delete this workout from server database
        else{
          pr("Error in parsing map");
        }
      }

      /// When no workout was found this checksum is old, so we remove it
      else{
        await database!.deleteWorkoutChecksum(checksum);
      }

    }
  }

  void refresh(){
    notifyListeners();
  }
}