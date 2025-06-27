import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../util/constants.dart';
import 'database_service.dart';

class CnSyncManager extends ChangeNotifier {
  String? userId;
  static DatabaseService? database;
  static List<String> localeChecksums = [];
  bool _isSyncing = false;

  CnSyncManager({this.userId}){
    setUserId(userId);
    // if(userId != null){
    //   database = DatabaseService(uid: userId!);
    // }
  }

  void setUserId(String? uid){
    userId = uid;
    if(userId != null){
      database = DatabaseService(uid: userId!);
    } else{
      database = null;
    }
  }

  Future doSyncWithFireStore() async{
    if(database == null || _isSyncing){
      return;
    }
    try{
      _isSyncing = true;
      if(await isOnline()){
        await FirebaseFirestore.instance.waitForPendingWrites();
      }

      final serverChecksumsFuture = database!.getServerChecksums();

      localeChecksums = objectbox.workoutBox.getAll().map((w) => w.checksum).toList();
      final ServerChecksums serverChecksums = await serverChecksumsFuture;

      await syncChecksums(serverChecksums: serverChecksums);
    }
    catch(e){
      pr("Error during Sync with Firestore");
      pr(e);
    }
    finally{
      _isSyncing = false;
    }
  }

  Future syncChecksums({required ServerChecksums serverChecksums}) async {

    pr("");
    pr("localChecksums: $localeChecksums");
    pr("serverChecksums: ${serverChecksums.checksums}");
    pr("");

    final List<String> missingLocal = serverChecksums.checksums.without(localeChecksums).whereType<String>().toList();
    final List<String> missingServer = localeChecksums.without(serverChecksums.checksums).whereType<String>().toList();

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
        database?.addWorkout(wo: woToDelete);
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

    if(missingLocal.isNotEmpty){
      /// Add missing Workouts from Server to local db
      List<Map<String, dynamic>> missingLocalMaps = await database!.getMultipleWorkoutsByChecksums(missingLocal);
      List<String> foundWorkoutsChecksums = [];

      for(Map<String, dynamic> woMap in missingLocalMaps){
        final ObWorkout? newWo = ObWorkout.fromMap(workoutMap: woMap, withExercises: true);
        if(newWo != null && woMap["checksum"] != null){
          pr("Workout: ${newWo.name} was found on serve, add it to client");
          newWo.save();
          localeChecksums.add(woMap["checksum"]);
          foundWorkoutsChecksums.add(woMap["checksum"]);
        }
        /// ToDo: when newWo is null, the map couldn't be parsed
        /// so we have to delete this workout from server database
        else{
          pr("Error in parsing map");
        }
      }

      for(String checksum in missingLocal.without(foundWorkoutsChecksums)){
        pr("Workout Checksum $checksum was not found on server, remove it");
        database?.deleteWorkoutChecksum(checksum);
      }
    }
  }

  void refresh(){
    notifyListeners();
  }
}