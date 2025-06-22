import 'package:cloud_firestore/cloud_firestore.dart';

import '../util/objectbox/ob_workout.dart';
import 'auto_commit_batch.dart';

class DatabaseService{

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final CollectionReference userCollection = firestore.collection('users');

  late final CollectionReference workoutCollection = userCollection.doc(uid).collection("workouts");
  late final DocumentReference userDocument = userCollection.doc(uid);
  final batch = AutoCommitBatch(firestore: firestore);

  final String uid;

  DatabaseService({required this.uid});

  Future<ServerChecksums> getServerChecksums() async{
    final DocumentSnapshot dc = await userCollection.doc(uid).get();
    final data = dc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey("workoutChecksums")) {
      final checksums = data["workoutChecksums"];
      final lastUpdated = data["lastUpdated"];
      if (checksums is List && lastUpdated is Timestamp) {
        return ServerChecksums(
            checksums: List<String>.from(checksums),
            lastUpdated: lastUpdated.toDate()
        );
      }
    }
    return ServerChecksums(checksums: []);
  }

  Future<Map<String, dynamic>?> getWorkoutByChecksum(String checksum) async{
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("workouts")
        .where("checksum", isEqualTo: checksum)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    return querySnapshot.docs.first.data();
  }

  Future<void> addWorkout({required ObWorkout wo, String? oldChecksum}) async{
    print("User ID in add workout: $uid");
    print(wo.uuid);
    print(userCollection.toString());
    // final batch = FirebaseFirestore.instance.batch();
    final workoutData = wo.asMap(withChecksum: true);

    await batch.set(workoutCollection.doc(wo.uuid), workoutData);

    await _addWorkoutChecksum(wo.checksum, batch: batch);
    if(oldChecksum != null){
      await deleteWorkoutChecksum(oldChecksum, batch: batch);
    }
    // batch.commit();
  }

  Future<void> _addWorkoutChecksum(String checksum, {AutoCommitBatch? batch}) async{
    if(batch != null){
      await batch.set(userDocument, {
        "workoutChecksums": FieldValue.arrayUnion([checksum]),
        "lastUpdated": FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
    else{
      await userDocument
          .set({
        "workoutChecksums": FieldValue.arrayUnion([checksum]),
        "lastUpdated": Timestamp.fromDate(DateTime.now())
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteWorkout({required ObWorkout wo}) async {
    // final batch = FirebaseFirestore.instance.batch();
    await batch.delete(workoutCollection.doc(wo.uuid));
    await deleteWorkoutChecksum(wo.currentChecksum, batch: batch);
    // batch.commit();
  }

  Future<void> deleteWorkoutChecksum(String checksum, {AutoCommitBatch? batch}) async {
    if(batch != null){
      await batch.set(userDocument, {
        "workoutChecksums": FieldValue.arrayRemove([checksum]),
        "lastUpdated": Timestamp.fromDate(DateTime.now())
      }, SetOptions(merge: true));
    }
    else{
      await userDocument
          .set({
        "workoutChecksums": FieldValue.arrayRemove([checksum]),
        "lastUpdated": Timestamp.fromDate(DateTime.now())
      }, SetOptions(merge: true));
    }
  }
  
}

class ServerChecksums{
  final List<String> checksums;
  final DateTime lastUpdated;

  ServerChecksums({
    required this.checksums,
    DateTime? lastUpdated
  }) : lastUpdated = lastUpdated?? DateTime(1970);
}