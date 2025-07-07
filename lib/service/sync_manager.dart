import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/backup_helper/save_current_data.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../screens/main_screens/screen_workout_history/screen_workout_history.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import '../screens/main_screens/screen_workouts/screen_workouts.dart';
import '../util/config.dart';
import '../util/constants.dart';
import '../util/objectbox/abstract_class_firebase_object.dart';
import '../util/objectbox/ob_sick_days.dart';
import 'database_service/collection.dart';
import 'database_service/database_service.dart';
import 'database_service/server_checksums.dart';

class CnSyncManager extends ChangeNotifier {
  static DatabaseService? database;

  String? userId;
  bool _isSyncing = false;

  late CnWorkoutHistory cnWorkoutHistory;
  late CnNewWorkOutPanel cnNewWorkout;
  late CnWorkouts cnWorkouts;
  late CnConfig cnConfig;

  CnSyncManager({this.userId, required BuildContext context}){
    setUserId(userId);
    cnWorkouts = context.read<CnWorkouts>();
    cnWorkoutHistory = context.read<CnWorkoutHistory>();
    cnNewWorkout = context.read<CnNewWorkOutPanel>();
    cnConfig = context.read<CnConfig>();
  }

  void setUserId(String? uid){
    userId = uid;
    if(userId != null){
      database = DatabaseService(uid: userId!);
    } else{
      database = null;
    }
  }

  Future doSyncWithFireStore(BuildContext context) async{
    if(database == null || _isSyncing){
      return;
    }
    try{
      _isSyncing = true;
      if(await isOnline()){
        await FirebaseFirestore.instance.waitForPendingWrites();
      }

      final serverChecksumsFuture = database!.getServerChecksums();

      final localChecksumsWorkouts = objectbox.workoutBox.getAll().map((w) => w.checksum).toList();
      final localChecksumsSickDays = objectbox.sickDaysBox.getAll().map((s) => s.checksum).toList();
      final ServerChecksums serverChecksums = await serverChecksumsFuture;

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          "Loading Account Data  ",
                          style: TextStyle(color: CupertinoColors.white)
                      ),
                      CupertinoActivityIndicator(
                          radius: 8.0,
                          color: Colors.amber[800]
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      await _syncChecksums(
          serverChecksums: serverChecksums.workoutChecksums,
          serverLastUpdated: serverChecksums.workoutChecksumsLastUpdated,
          constructorFromMap: (Map<String, dynamic> map) => ObWorkout.fromMap(workoutMap: map, withExercises: true),
          collection: Collection.workouts,
          localChecksums: localChecksumsWorkouts,
          getLocalObjectByChecksum: (String checksum) => objectbox.workoutBox.query(ObWorkout_.checksum.equals(checksum)).build().findFirst(),
          refresh: () async {
            await cnWorkouts.refreshAllWorkouts();
            await cnWorkoutHistory.refreshAllWorkouts();
            cnNewWorkout.refreshAllWorkoutDays();
          },
          box: objectbox.workoutBox
      );

      await _syncChecksums(
          serverChecksums: serverChecksums.sickDayChecksums,
          serverLastUpdated: serverChecksums.sickDayChecksumsLastUpdated,
          constructorFromMap: (Map<String, dynamic> map) => ObSickDays.fromMap(sickDaysMap: map),
          collection: Collection.sickDays,
          localChecksums: localChecksumsSickDays,
          getLocalObjectByChecksum: (String checksum) => objectbox.sickDaysBox.query(ObSickDays_.checksum.equals(checksum)).build().findFirst(),
          refresh: () async {
            await cnWorkouts.refreshAllWorkouts();
            await cnWorkoutHistory.refreshAllWorkouts();
            cnNewWorkout.refreshAllWorkoutDays();
          },
          box: objectbox.sickDaysBox
      );

      overlayEntry.remove();
    }
    catch(e){
      pr("Error during Sync with Firestore");
      pr(e);
    }
    finally{
      _isSyncing = false;
    }
  }

  Future _syncChecksums({
    required List<String> serverChecksums,
    required DateTime serverLastUpdated,
    required List<String> localChecksums,
    required Collection collection,
    required FirebaseObject? Function(Map<String, dynamic>) constructorFromMap,
    required FirebaseObject? Function(String) getLocalObjectByChecksum,
    required Future Function() refresh,
    required Box box
  }) async {
    pr("");
    pr("localChecksums: $localChecksums");
    pr("serverChecksums: $serverChecksums");
    pr("");

    final List<String> missingLocal = serverChecksums.without(localChecksums).whereType<String>().toList();
    final List<String> missingServer = localChecksums.without(serverChecksums).whereType<String>().toList();

    pr("");
    pr("MissingLocal: $missingLocal");
    pr("MissingServer: $missingServer");
    pr("");

    /// Remove local workouts that are not on server db
    /// when the lastUpdated is larger than the workouts timestamp
    for (String checksum in missingServer) {
      final FirebaseObject? objectToDelete = getLocalObjectByChecksum(checksum);

      if(objectToDelete == null){
        continue;
      }

      /// Workout was saved locally after last Server Update
      /// so we add it to server backend
      if(objectToDelete.lastUpdated?.isAfter(serverLastUpdated) ?? false){
        pr("Object is missing on server side, but newer than last sync. Add it to Server");
        await database?.addCollectionObject(object: objectToDelete);
      }

      /// Workout was last Updated before the last server update
      /// So this workout is old, remove it from client side
      else{
        pr("Object is missing on server side and older than last sync, remove it from client");
        box.remove(objectToDelete.id);
      }
    }

    if(missingLocal.isNotEmpty){
      /// Add missing SickDays from Server to local db
      List<Map<String, dynamic>> missingLocalMaps = await database!.getMultipleEntriesByChecksums(checksums: missingLocal, collection: collection);
      List<String> foundChecksums = [];

      int counter = 0;

      for(Map<String, dynamic> objectMap in missingLocalMaps){
        final FirebaseObject? newObject = constructorFromMap(objectMap);
        if(newObject != null && objectMap["checksum"] != null){
          pr("Object was found on server, add it to client");
          await newObject.save();
          foundChecksums.add(objectMap["checksum"]);
          counter += 1;
          if (counter % 10 == 0){
            await refresh();
          }
        }
        /// ToDo: when newObject is null, the map couldn't be parsed
        /// so we have to delete this newObject from server database
        else{
          pr("Error in parsing map");
        }
      }

      for(String checksum in missingLocal.without(foundChecksums)){
        pr("Checksum $checksum was not found on server, remove it");
        await database?.deleteChecksum(checksum, collection: collection);
      }

      await refresh();
      saveCurrentData(cnConfig);
    }
  }

  void refresh(){
    notifyListeners();
  }
}
