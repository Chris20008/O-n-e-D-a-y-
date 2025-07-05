import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/service/database_service/server_checksums.dart';
import 'package:fitness_app/service/sync_manager.dart';
import 'package:fitness_app/util/objectbox/abstract_class_firebase_object.dart';

import '../../main.dart';
import '../auto_commit_batch.dart';
import 'collection.dart';

class DatabaseService{

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final CollectionReference userCollection = firestore.collection('users');

  late final CollectionReference<Map<String, dynamic>> workoutCollection = userCollection.doc(uid).collection("workouts");
  late final CollectionReference<Map<String, dynamic>> sickDayCollection = userCollection.doc(uid).collection("sickDays");
  late final DocumentReference userDocument = userCollection.doc(uid);

  final writeBatch = AutoCommitBatch(firestore: firestore);
  final String uid;

  DatabaseService({required this.uid});

  /// -------------------------------------------------------------------------------------
  /// -------------------------------------- Getter ---------------------------------------
  /// -------------------------------------------------------------------------------------

  Future<ServerChecksums> getServerChecksums() async{
    final DocumentSnapshot dc = await userCollection.doc(uid).get();
    final data = dc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey("workoutChecksums") && data.containsKey("sickDayChecksums")) {
      final workoutChecksums = data["workoutChecksums"];
      final sickDayChecksums = data["sickDayChecksums"];
      final workoutChecksumsLastUpdated = data["workoutChecksumsLastUpdated"];
      final sickDayChecksumsLastUpdated = data["sickDayChecksumsLastUpdated"];

      if (workoutChecksums is List
          && workoutChecksumsLastUpdated is Timestamp
          && sickDayChecksums is List
          && sickDayChecksumsLastUpdated is Timestamp
      ) {
        return ServerChecksums(
            workoutChecksums: List<String>.from(workoutChecksums),
            sickDayChecksums: List<String>.from(sickDayChecksums),
            workoutChecksumsLastUpdated: workoutChecksumsLastUpdated.toDate(),
            sickDayChecksumsLastUpdated: sickDayChecksumsLastUpdated.toDate()
        );
      }
    }
    return ServerChecksums(workoutChecksums: [], sickDayChecksums: []);
  }

  CollectionReference<Map<String, dynamic>> getCollection(Collection collection){
    if(collection == Collection.workouts){
      return workoutCollection;
    }
    return sickDayCollection;
  }

  Future<List<Map<String, dynamic>>> getMultipleEntriesByChecksums({
    required List<String> checksums,
    required Collection collection
  }) async {
    const batchSize = 10;
    final List<Map<String, dynamic>> allSickDays = [];
    final CollectionReference<Map<String, dynamic>> col = getCollection(collection);

    for (var i = 0; i < checksums.length; i += batchSize) {
      final batch = checksums.sublist(
        i,
        i + batchSize > checksums.length ? checksums.length : i + batchSize,
      );

      final querySnapshot = await col
          .where("checksum", whereIn: batch)
          .get();

      allSickDays.addAll(querySnapshot.docs.map((doc) => doc.data()));
    }

    return allSickDays;
  }

  /// -------------------------------------------------------------------------------------
  /// -------------------------------------- Workout --------------------------------------
  /// -------------------------------------------------------------------------------------

  // Future<void> addWorkout({required ObWorkout wo, String? oldChecksum}) async{
  //   final workoutData = wo.asMap(withChecksum: true);
  //
  //   await writeBatch.set(workoutCollection.doc(wo.uuid), workoutData);
  //
  //   await _addWorkoutChecksum(wo.checksum, batch: writeBatch);
  //   if(oldChecksum != null){
  //     await deleteWorkoutChecksum(oldChecksum, batch: writeBatch);
  //   }
  // }
  //
  // Future<void> _addWorkoutChecksum(String checksum, {AutoCommitBatch? batch}) async{
  //   if(batch != null){
  //     await batch.set(userDocument, {
  //       "workoutChecksums": FieldValue.arrayUnion([checksum]),
  //       "workoutChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
  //     }, SetOptions(merge: true));
  //   }
  //   else{
  //     await userDocument
  //         .set({
  //       "workoutChecksums": FieldValue.arrayUnion([checksum]),
  //       "workoutChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
  //     }, SetOptions(merge: true));
  //   }
  // }
  //
  // Future<void> deleteWorkout({required ObWorkout wo}) async {
  //   await writeBatch.delete(workoutCollection.doc(wo.uuid));
  //   await deleteWorkoutChecksum(wo.currentChecksum, batch: writeBatch);
  // }
  //
  // Future<void> deleteWorkoutChecksum(String checksum, {AutoCommitBatch? batch}) async {
  //   if(batch != null){
  //     await batch.set(userDocument, {
  //       "workoutChecksums": FieldValue.arrayRemove([checksum]),
  //       "workoutChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
  //     }, SetOptions(merge: true));
  //   }
  //   else{
  //     await userDocument
  //         .set({
  //       "workoutChecksums": FieldValue.arrayRemove([checksum]),
  //       "workoutChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
  //     }, SetOptions(merge: true));
  //   }
  // }

  /// -------------------------------------------------------------------------------------
  /// --------------------------- Handle Collection Objects -------------------------------
  /// -------------------------------------------------------------------------------------

  Future<void> addCollectionObject({required FirebaseObject object, String? oldChecksum}) async{
    final data = object.asMap(withChecksum: true);
    final col = getCollection(object.collection);

    await writeBatch.set(col.doc(object.uuid), data);

    await _addChecksum(object.checksum, batch: writeBatch, collection: object.collection);
    if(oldChecksum != null){
      await deleteChecksum(oldChecksum, batch: writeBatch, collection: object.collection);
    }
  }

  Future<void> _addChecksum(String checksum, {AutoCommitBatch? batch, required Collection collection}) async{
    final map = collection.checksumMap(checksum, FieldValue.arrayUnion);
    if(batch != null){
      await batch.set(userDocument, map, SetOptions(merge: true));
    }
    else{
      await userDocument.set(map, SetOptions(merge: true));
    }
  }

  Future<void> deleteCollectionObject({required FirebaseObject object}) async {
    final col = getCollection(object.collection);
    await writeBatch.delete(col.doc(object.uuid));
    await deleteChecksum(object.currentChecksum, batch: writeBatch, collection: object.collection);
  }

  Future<void> deleteChecksum(String checksum, {AutoCommitBatch? batch, required Collection collection}) async {
    final map = collection.checksumMap(checksum, FieldValue.arrayRemove);
    if(batch != null){
      await batch.set(userDocument, map, SetOptions(merge: true));
    }
    else{
      await userDocument.set(map, SetOptions(merge: true));
    }
  }

  /// -------------------------------------------------------------------------------------
  /// -------------------------------------- Other ----------------------------------------
  /// -------------------------------------------------------------------------------------

  Future<void> deleteAllData() async{
    final database =  CnSyncManager.database;
    if(database == null){
      return;
    }
    final serverChecksums = await database.getServerChecksums();
    final allWorkouts =  objectbox.workoutBox.getAll();
    final allSickDays =  objectbox.sickDaysBox.getAll();

    /// Delete All Workouts in Firestore
    for(String checksum in serverChecksums.workoutChecksums){
      final ob = allWorkouts.firstWhereOrNull((wo) => wo.checksum == checksum);
      if(ob == null){
        continue;
      }
      await database.deleteCollectionObject(object: ob);
    }

    /// Delete all Sick Days in Firestore
    for(String checksum in serverChecksums.sickDayChecksums){
      final ob = allSickDays.firstWhereOrNull((sd) => sd.checksum == checksum);
      if(ob == null){
        continue;
      }
      await database.deleteCollectionObject(object: ob);
    }

    /// wait until all collection objects are truly commited
    await Future.delayed(writeBatch.autoCommitDuration*2);
    await userCollection.doc(uid).delete();
  }
}